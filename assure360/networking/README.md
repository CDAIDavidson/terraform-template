# Assure360 Networking (VPC + ALB + ECS + Endpoints)

Single-AZ VPC with public + private subnets, NAT, S3 gateway + interface endpoints (ECR, ECS, Logs), ALB (HTTP→HTTPS), ACM placeholder, and ECS(Fargate) pulling from ECR.

## What This Creates

### VPC Infrastructure
- **VPC**: 10.10.0.0/16 with DNS hostnames and support enabled
- **Public Subnet**: 10.10.0.0/19 in ap-southeast-2a with internet gateway
- **Private App Subnet**: 10.10.32.0/19 in ap-southeast-2a with NAT gateway
- **Internet Gateway**: For public subnet internet access
- **NAT Gateway**: For private subnet outbound internet access

### VPC Endpoints
- **S3 Gateway Endpoint**: For ECR layer pulls and S3 access
- **Interface Endpoints**: ECR API, ECR DKR, CloudWatch Logs, ECS, ECS Telemetry
- **Private DNS**: Enabled for all interface endpoints

### Application Load Balancer
- **ALB**: Internet-facing with HTTP→HTTPS redirect
- **Target Group**: IP-based for ECS Fargate tasks
- **Health Checks**: HTTP on port 8080
- **ACM Certificate**: DNS validation placeholder

### ECS Infrastructure
- **ECS Cluster**: Fargate cluster for containerized applications
- **Task Definition**: 512 CPU, 1024 MB memory, port 8080
- **ECS Service**: Fargate service with ALB integration
- **CloudWatch Logs**: Centralized logging for ECS tasks
- **IAM Role**: Task execution role with ECR permissions

### Security Groups
- **ALB SG**: HTTPS (443) and optional HTTP (80) from internet
- **ECS Tasks SG**: Traffic from ALB only
- **VPC Endpoints SG**: Internal VPC traffic only

## Prerequisites

- AWS credentials configured for the target account
- **AWS_PROFILE** set in your terminal before running scripts
- ECR image available at `ecr_repo_url` (or create the optional ECR repo and push first)
- Validate CIDRs do **not** overlap with on-prem/VPN networks
- Appropriate AWS permissions for VPC, ECS, ALB, and IAM resources

## Quick Start

```bash
export AWS_PROFILE=dev-assure360
cd assure360/networking
cp .env.example .env   # edit values as needed
terraform init
chmod +x plan.sh apply.sh
./plan.sh
yes

```

## Configuration

### Important Variables (via .env or tfvars)

- **TF_VAR_region** – default ap-southeast-2
- **TF_VAR_name** – resource name prefix
- **TF_VAR_ecr_repo_url** – required image repo (1111.dkr.ecr.../myrepo)
- **CIDRs**: TF_VAR_vpc_cidr, TF_VAR_public_cidr_a, TF_VAR_private_app_cidr_a
- **TLS**: TF_VAR_domain_name (ACM placeholder)

**Note**: AWS profile must be set manually in terminal: `export AWS_PROFILE=your-profile-name`

### Environment File Setup

```bash
# Copy the example file
cp .env.example .env

# Edit with your values
nano .env
```

### Required Variables

You must set these variables before applying:

```bash
# ECR repository URL (required)
TF_VAR_ecr_repo_url=111122223333.dkr.ecr.ap-southeast-2.amazonaws.com/myrepo

# AWS profile
TF_VAR_aws_profile=AdminAssure360
```

## Step-by-Step Instructions

### Step 1: Navigate to Directory
```bash
cd assure360/networking
```

### Step 2: Configure Environment
```bash
# Copy the example file
cp .env.example .env

# Edit .env with your configuration
nano .env
```

### Step 3: Set AWS Profile
```bash
# Set to your target account profile (REQUIRED before running scripts)
export AWS_PROFILE=your-aws-profile
```

### Step 4: Initialize Terraform
```bash
# IMPORTANT: Run this first before planning or applying
terraform init
```

### Step 5: Review Plan
```bash
chmod +x plan.sh
./plan.sh
```

### Step 6: Deploy
```bash
chmod +x apply.sh
./apply.sh
```

## Verify Deployment

### Check VPC and Subnets
```bash
terraform output vpc_id
terraform output public_subnet_id_a
terraform output private_app_subnet_a
```

### Check ALB
```bash
terraform output alb_dns_name
# Test: curl -I http://$(terraform output -raw alb_dns_name)
```

### Check ECS
```bash
terraform output ecs_cluster_name
aws ecs list-clusters
aws ecs list-services --cluster $(terraform output -raw ecs_cluster_name)
```

### Check VPC Endpoints
```bash
aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"
```

## Architecture Details

### Network Layout
```
Internet Gateway
       |
   Public Subnet (10.10.0.0/19)
       |
   NAT Gateway
       |
Private App Subnet (10.10.32.0/19)
       |
   ECS Tasks (Fargate)
       |
   ALB Target Group
```

### Security Flow
```
Internet → ALB (443/80) → ECS Tasks (8080) → VPC Endpoints
```

### VPC Endpoints
- **S3 Gateway**: Reduces data transfer costs for ECR pulls
- **ECR API/DKR**: Private container registry access
- **CloudWatch Logs**: Centralized logging without internet
- **ECS/ECS Telemetry**: Container orchestration and monitoring

## Cost Considerations

### NAT Gateway
- **Hourly Cost**: ~$45/month per NAT Gateway
- **Data Processing**: $0.045 per GB processed
- **Consider**: Use NAT Instance for cost savings in dev/test

### ALB
- **Hourly Cost**: ~$16/month per ALB
- **LCU Cost**: $0.008 per LCU-hour
- **Consider**: Use NLB for high-throughput, low-latency workloads

### ECS Fargate
- **vCPU**: $0.04048 per vCPU per hour
- **Memory**: $0.004445 per GB per hour
- **Consider**: Use Spot instances for non-critical workloads

## Security Features

### Network Security
- Private subnets for application workloads
- Security groups with least privilege access
- VPC endpoints for private AWS service access

### Application Security
- HTTPS-only traffic (HTTP redirects to HTTPS)
- ACM certificate for SSL/TLS termination
- Container image scanning enabled (if using ECR)

### Monitoring
- CloudWatch Logs for centralized logging
- ECS service health checks
- ALB health checks and metrics

## Troubleshooting

### ECS Service Won't Start
1. Check ECR repository URL is correct
2. Verify image exists and is accessible
3. Check ECS task definition logs
4. Ensure security groups allow traffic

### ALB Health Checks Failing
1. Verify application listens on port 8080
2. Check health check path returns 200
3. Ensure security groups allow ALB→ECS traffic
4. Check CloudWatch Logs for application errors

### VPC Endpoints Not Working
1. Verify private DNS is enabled
2. Check security group allows VPC traffic
3. Ensure subnets have proper route tables
4. Test from within the VPC

### Certificate Issues
1. Add DNS validation records for your domain
2. Wait for certificate validation (can take 30+ minutes)
3. Verify domain ownership in Route 53

## Next Steps

After successful deployment:

1. **Push your application image** to the ECR repository
2. **Configure DNS** to point to the ALB DNS name
3. **Add ACM DNS validation records** for your domain
4. **Monitor** CloudWatch Logs and ECS service health
5. **Scale** ECS service as needed for your workload

## Configuration Files

- **`versions.tf`**: Terraform and provider version constraints
- **`providers.tf`**: AWS provider configuration
- **`variables.tf`**: Input variable definitions
- **`locals.tf`**: Local values and common tags
- **`vpc.tf`**: VPC, subnets, gateways, and routing
- **`endpoints.tf`**: VPC endpoints for AWS services
- **`security.tf`**: Security groups for ALB and ECS
- **`alb_ecs.tf`**: Application Load Balancer and ECS resources
- **`ecr.tf`**: Optional ECR repository creation
- **`outputs.tf`**: Output values for integration
- **`.env.example`**: Environment variable template
- **`plan.sh`**: Shell script for running `terraform plan`
- **`apply.sh`**: Shell script for running `terraform apply`

## Integration with Other Modules

This networking module can be integrated with:

- **IAM Foundation**: Use existing IAM roles and policies
- **IAM Users**: Deploy with appropriate user permissions
- **Database Modules**: Add RDS in private subnets
- **Monitoring**: Integrate with CloudWatch and X-Ray

## Support

For issues or questions:

1. Check the troubleshooting section above
2. Review CloudWatch Logs for application errors
3. Verify AWS permissions and resource limits
4. Consult AWS documentation for specific services
