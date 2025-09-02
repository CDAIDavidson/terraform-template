# Networking Module

This module creates a complete VPC infrastructure with public/private subnets, NAT gateways, routing, and security features. It's designed to be flexible, secure, and production-ready.

## Overview

The Networking Module provides:
- ✅ **VPC**: Custom VPC with DNS support
- ✅ **Subnets**: Public and private subnets across multiple AZs
- ✅ **Internet Gateway**: For public subnet internet access
- ✅ **NAT Gateways**: For private subnet internet access (optional)
- ✅ **Route Tables**: Proper routing for public and private subnets
- ✅ **Security Groups**: Default security group with egress rules
- ✅ **VPC Flow Logs**: Network traffic monitoring (optional)
- ✅ **VPN Gateway**: Site-to-site VPN support (optional)
- ✅ **Validation**: Input validation for CIDR blocks and configurations

## Prerequisites

1. **AWS Account**: Active AWS account with appropriate permissions
2. **Terraform**: Version 1.0 or later
3. **AWS CLI**: Configured with appropriate credentials
4. **Permissions**: VPC, EC2, IAM, and CloudWatch permissions

## Quick Start

### 1. Configure Environment

```bash
# Copy the example configuration
cp env.example .env

# Edit .env with your actual values
nano .env
```

### 2. Set Required Variables

```bash
# Project Configuration
TF_VAR_project_name="MyProject"

# VPC Configuration
TF_VAR_vpc_cidr_block="10.0.0.0/16"

# Subnet Configuration
TF_VAR_public_subnet_cidrs='["10.0.1.0/24", "10.0.2.0/24"]'
TF_VAR_private_subnet_cidrs='["10.0.10.0/24", "10.0.20.0/24"]'
```

### 3. Deploy

```bash
# Plan the deployment
./plan.sh

# Apply the changes
./apply.sh
```

### 4. Get Network Information

```bash
# Get VPC ID
terraform output vpc_id

# Get subnet IDs
terraform output public_subnet_ids
terraform output private_subnet_ids
```

## Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `project_name` | Name of the project (used for resource naming) | `"MyProject"` |

### Optional Variables

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `vpc_cidr_block` | CIDR block for the VPC | `"10.0.0.0/16"` | `"10.1.0.0/16"` |
| `availability_zones` | List of AZs (empty = all available) | `[]` | `["us-east-1a", "us-east-1b"]` |
| `public_subnet_cidrs` | CIDR blocks for public subnets | `["10.0.1.0/24", "10.0.2.0/24"]` | `["10.0.1.0/24"]` |
| `private_subnet_cidrs` | CIDR blocks for private subnets | `["10.0.10.0/24", "10.0.20.0/24"]` | `["10.0.10.0/24"]` |
| `enable_nat_gateway` | Enable NAT Gateway for private subnets | `true` | `false` |
| `enable_vpn_gateway` | Enable VPN Gateway | `false` | `true` |
| `enable_flow_logs` | Enable VPC Flow Logs | `true` | `false` |
| `flow_log_retention_days` | CloudWatch log retention | `30` | `90` |
| `tags` | Tags to apply to all resources | `{}` | `{"Environment": "prod"}` |

### Variable Validation

The module includes comprehensive validation:

- **VPC CIDR**: Valid CIDR block format
- **Availability Zones**: Maximum 6 zones
- **Subnet CIDRs**: 1-6 CIDR blocks each
- **Flow Log Retention**: 1-3653 days

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        VPC (10.0.0.0/16)                   │
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │   Public AZ-1   │    │   Public AZ-2   │                │
│  │  (10.0.1.0/24)  │    │  (10.0.2.0/24)  │                │
│  │                 │    │                 │                │
│  │  ┌───────────┐  │    │  ┌───────────┐  │                │
│  │  │    IGW    │  │    │  │    IGW    │  │                │
│  │  └───────────┘  │    │  └───────────┘  │                │
│  └─────────────────┘    └─────────────────┘                │
│           │                       │                        │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │  Private AZ-1   │    │  Private AZ-2   │                │
│  │ (10.0.10.0/24)  │    │ (10.0.20.0/24)  │                │
│  │                 │    │                 │                │
│  │  ┌───────────┐  │    │  ┌───────────┐  │                │
│  │  │    NAT    │  │    │  │    NAT    │  │                │
│  │  │  Gateway  │  │    │  │  Gateway  │  │                │
│  │  └───────────┘  │    │  └───────────┘  │                │
│  └─────────────────┘    └─────────────────┘                │
└─────────────────────────────────────────────────────────────┘
```

## Outputs

### VPC Information
| Output | Description |
|--------|-------------|
| `vpc_id` | ID of the VPC |
| `vpc_cidr_block` | CIDR block of the VPC |
| `vpc_arn` | ARN of the VPC |

### Subnet Information
| Output | Description |
|--------|-------------|
| `public_subnet_ids` | IDs of the public subnets |
| `private_subnet_ids` | IDs of the private subnets |
| `public_subnet_cidrs` | CIDR blocks of the public subnets |
| `private_subnet_cidrs` | CIDR blocks of the private subnets |
| `public_subnet_arns` | ARNs of the public subnets |
| `private_subnet_arns` | ARNs of the private subnets |

### Gateway Information
| Output | Description |
|--------|-------------|
| `internet_gateway_id` | ID of the Internet Gateway |
| `nat_gateway_ids` | IDs of the NAT Gateways |
| `nat_gateway_public_ips` | Public IPs of the NAT Gateways |
| `nat_gateway_private_ips` | Private IPs of the NAT Gateways |
| `vpn_gateway_id` | ID of the VPN Gateway (if enabled) |

### Security Information
| Output | Description |
|--------|-------------|
| `default_security_group_id` | ID of the default security group |
| `vpc_flow_log_id` | ID of the VPC Flow Log (if enabled) |
| `vpc_flow_log_cloudwatch_log_group` | CloudWatch Log Group for Flow Logs |

### Route Table Information
| Output | Description |
|--------|-------------|
| `public_route_table_id` | ID of the public route table |
| `private_route_table_ids` | IDs of the private route tables |

### Computed Values
| Output | Description |
|--------|-------------|
| `availability_zones` | List of availability zones used |
| `subnet_count` | Number of subnets created |

## Security Features

### VPC Flow Logs
- **Traffic Monitoring**: Logs all VPC traffic
- **CloudWatch Integration**: Centralized logging
- **Configurable Retention**: 1-3653 days
- **Cost Optimization**: Optional feature

### Security Groups
- **Default Security Group**: Created for each VPC
- **Egress Rules**: Allow all outbound traffic
- **No Ingress Rules**: Secure by default
- **Customizable**: Add ingress rules as needed

### Network Isolation
- **Public Subnets**: Direct internet access via IGW
- **Private Subnets**: Internet access via NAT Gateway
- **Route Separation**: Different route tables for public/private
- **AZ Distribution**: Resources spread across availability zones

## Usage Examples

### Basic VPC Setup
```bash
# Minimal configuration
export TF_VAR_project_name="MyProject"
terraform apply
```

### Custom VPC with Specific AZs
```bash
# Use specific availability zones
export TF_VAR_project_name="MyProject"
export TF_VAR_availability_zones='["us-east-1a", "us-east-1b", "us-east-1c"]'
export TF_VAR_public_subnet_cidrs='["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]'
export TF_VAR_private_subnet_cidrs='["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]'
terraform apply
```

### VPC without NAT Gateway
```bash
# Cost-optimized setup (no NAT Gateway)
export TF_VAR_project_name="MyProject"
export TF_VAR_enable_nat_gateway=false
terraform apply
```

### VPC with VPN Gateway
```bash
# Enable VPN Gateway for site-to-site connectivity
export TF_VAR_project_name="MyProject"
export TF_VAR_enable_vpn_gateway=true
terraform apply
```

### VPC with Custom Flow Logs
```bash
# Custom flow log configuration
export TF_VAR_project_name="MyProject"
export TF_VAR_enable_flow_logs=true
export TF_VAR_flow_log_retention_days=90
terraform apply
```

## Cost Optimization

### NAT Gateway Costs
- **Cost**: ~$45/month per NAT Gateway
- **Optimization**: Use `enable_nat_gateway=false` for cost savings
- **Alternative**: Use NAT instances for lower cost

### VPC Flow Logs
- **Cost**: CloudWatch log storage and ingestion
- **Optimization**: Adjust retention period based on needs
- **Alternative**: Use S3 for long-term storage

### Elastic IPs
- **Cost**: Free when attached to running resources
- **Optimization**: NAT Gateways automatically manage EIPs

## Integration with Other Modules

### With Account Module
```bash
# Get account ID from account module
ACCOUNT_ID=$(cd ../account && terraform output -raw account_id)

# Use in networking module
terraform apply -var="account_id=$ACCOUNT_ID"
```

### With Users Module
```bash
# Get VPC and subnet IDs for user policies
VPC_ID=$(terraform output -raw vpc_id)
PUBLIC_SUBNETS=$(terraform output -json public_subnet_ids)

# Use in users module
cd ../users
terraform apply -var="vpc_id=$VPC_ID" -var="public_subnet_ids=$PUBLIC_SUBNETS"
```

## Troubleshooting

### Common Issues

#### 1. CIDR Block Conflicts
```
Error: CIDR block conflicts with existing VPC
```
**Solution**: Choose a different CIDR block that doesn't conflict with existing VPCs.

#### 2. Insufficient Availability Zones
```
Error: Not enough availability zones
```
**Solution**: Ensure you have at least 2 availability zones in your region.

#### 3. NAT Gateway Creation Failed
```
Error: NAT Gateway creation failed
```
**Solution**: Check that public subnets exist and have internet gateway access.

#### 4. Flow Logs Permission Denied
```
Error: Permission denied for CloudWatch logs
```
**Solution**: Ensure your AWS credentials have CloudWatch and IAM permissions.

### Verification Steps

#### 1. Check VPC Status
```bash
# Verify VPC was created
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_id)
```

#### 2. Test Subnet Connectivity
```bash
# Check subnet configuration
aws ec2 describe-subnets --subnet-ids $(terraform output -json public_subnet_ids | jq -r '.[0]')
```

#### 3. Verify NAT Gateway
```bash
# Check NAT Gateway status
aws ec2 describe-nat-gateways --nat-gateway-ids $(terraform output -json nat_gateway_ids | jq -r '.[0]')
```

#### 4. Test Flow Logs
```bash
# Check CloudWatch log group
aws logs describe-log-groups --log-group-name-prefix "/aws/vpc/flowlogs"
```

## Best Practices

### 1. CIDR Planning
- Use non-overlapping CIDR blocks
- Plan for future growth
- Document CIDR allocations

### 2. Availability Zone Strategy
- Use at least 2 AZs for high availability
- Distribute resources evenly across AZs
- Consider AZ-specific services

### 3. Security Group Design
- Start with restrictive rules
- Use security group references
- Document rule purposes

### 4. Monitoring and Logging
- Enable VPC Flow Logs for production
- Set up CloudWatch alarms
- Monitor NAT Gateway costs

### 5. Tagging Strategy
- Apply consistent tags
- Include Environment, Project, Owner
- Use tags for cost allocation

## Cost Considerations

### Monthly Costs (US East 1)
- **VPC**: Free
- **Internet Gateway**: Free
- **NAT Gateway**: ~$45/month per gateway
- **Elastic IP**: Free when attached
- **VPC Flow Logs**: ~$0.50/GB ingested
- **CloudWatch Logs**: ~$0.50/GB stored

### Cost Optimization Tips
1. **Use NAT Instances**: For lower cost than NAT Gateways
2. **Optimize Flow Logs**: Use S3 for long-term storage
3. **Right-size Subnets**: Don't over-provision CIDR blocks
4. **Monitor Usage**: Set up billing alerts

## Next Steps

After creating the networking infrastructure:

1. **Deploy Applications**: Use the subnets for EC2, RDS, etc.
2. **Set up Load Balancers**: Use public subnets for ALB/NLB
3. **Configure Databases**: Use private subnets for RDS
4. **Set up Monitoring**: Configure CloudWatch alarms
5. **Security Hardening**: Add additional security groups and NACLs

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review AWS VPC documentation
3. Check Terraform AWS provider documentation
4. Verify your AWS permissions and configuration
