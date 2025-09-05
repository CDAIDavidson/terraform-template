# Assure360 Test App

A simple serverless Python application for testing CI/CD pipelines with GitHub Actions and AWS.

## 🎯 **Purpose**

This test app validates your GitHub Actions CI/CD setup by:
- Building and deploying a real application
- Testing AWS OIDC authentication
- Verifying end-to-end deployment pipeline
- Providing a clean test environment

## 🏗️ **Architecture**

```
GitHub Repo → GitHub Actions → ECR → Lambda (Docker) → API Gateway → Public URL
```

### **Components:**
- **FastAPI Python App** - Simple REST API with multiple endpoints
- **Docker Container** - Containerized for AWS Lambda
- **AWS Lambda** - Serverless compute (Python 3.11)
- **API Gateway** - HTTP API endpoint
- **ECR Repository** - Docker image storage
- **CloudWatch Logs** - Application monitoring

## 🚀 **Quick Start**

### **Option 1: Run Locally with Docker (Recommended for Testing)**
```bash
# Navigate to the test-app directory
cd assure360/test-app

# Run with Docker
./run-docker.sh
```

### **Option 2: Run Locally with Python**
```bash
# Navigate to the test-app directory
cd assure360/test-app

# Run with Python
./run-local.sh
```

### **Option 3: Deploy to AWS**
```bash
# Navigate to the test-app directory
cd assure360/test-app

# Deploy to AWS
./deploy.sh
```

### **Option 4: Use GitHub Actions (CI/CD)**
```bash
# Navigate to the test-app directory
cd assure360/test-app

# Setup CI/CD (copies workflow to main repo)
./setup-cicd.sh

# Commit and push the workflow
git add .github/workflows/deploy-test-app.yml
git commit -m "Add test app CI/CD workflow"
git push origin main
```

## 🐳 **Local Docker Development**

### **Quick Docker Commands:**
```bash
# Navigate to the test-app directory
cd assure360/test-app

# Build and run
./run-docker.sh

# Run with Docker Compose
./run-docker.sh compose

# View logs
./run-docker.sh logs

# Clean up
./run-docker.sh cleanup
```

### **Manual Docker Commands:**
```bash
# Navigate to the test-app directory
cd assure360/test-app

# Build image
docker build -f app/Dockerfile.local -t assure360-test-app-local ./app

# Run container
docker run -d --name assure360-test-app -p 8080:8080 assure360-test-app-local

# Test endpoints
curl http://localhost:8080/health
curl http://localhost:8080/hello

# Stop container
docker stop assure360-test-app
docker rm assure360-test-app
```

### **Docker Compose:**
```bash
# Navigate to the test-app directory
cd assure360/test-app

# Start with compose
docker-compose up --build

# Run in background
docker-compose up -d --build

# Stop
docker-compose down
```

## 🏗️ **AWS Deployment**

### **1. Deploy Infrastructure**
```bash
# Navigate to the test-app directory
cd assure360/test-app

# Deploy infrastructure
cd infrastructure
terraform init
terraform plan
terraform apply
```

### **2. Build and Deploy App**
```bash
# Navigate to the test-app directory
cd assure360/test-app

# Build Docker image
cd app
docker build -t assure360-test-app .

# Tag and push to ECR
aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-southeast-2.amazonaws.com
docker tag assure360-test-app:latest $(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-southeast-2.amazonaws.com/assure360-test-app:latest
docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-southeast-2.amazonaws.com/assure360-test-app:latest

# Update Lambda function
aws lambda update-function-code --function-name assure360-test-app --image-uri $(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-southeast-2.amazonaws.com/assure360-test-app:latest
```

### **3. Test the API**
```bash
# Navigate to the test-app directory
cd assure360/test-app

# Get API URL
API_URL=$(cd infrastructure && terraform output -raw api_url)

# Test endpoints
curl $API_URL/health
curl $API_URL/hello
curl $API_URL/test
```

## 🔄 **CI/CD Pipeline**

### **Automatic Deployment:**
- **Push to `main`** → Deploys to production
- **Push to `dev`** → Deploys to development
- **Pull Request** → Runs tests only

### **Manual Actions:**
- **Destroy Resources** → Clean up all resources
- **Redeploy** → Force new deployment

## 📡 **API Endpoints**

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Root endpoint with app info |
| `/health` | GET | Health check for monitoring |
| `/hello` | GET | Hello world with optional name parameter |
| `/time` | GET | Current time in various formats |
| `/status` | GET | Detailed status information |
| `/info` | GET | App and environment information |
| `/test` | GET | CI/CD validation endpoint |
| `/docs` | GET | Interactive API documentation |

### **Example Requests:**
```bash
# Basic health check
curl https://your-api-id.execute-api.ap-southeast-2.amazonaws.com/prod/health

# Hello with name
curl "https://your-api-id.execute-api.ap-southeast-2.amazonaws.com/prod/hello?name=Chris"

# Get current time
curl https://your-api-id.execute-api.ap-southeast-2.amazonaws.com/prod/time
```

## 🧪 **Testing**

### **Automated Tests:**
The CI/CD pipeline automatically tests:
- ✅ **Health endpoint** responds correctly
- ✅ **Hello endpoint** returns expected JSON
- ✅ **Test endpoint** validates deployment
- ✅ **All endpoints** return valid responses

### **Manual Testing:**
```bash
# Navigate to the test-app directory
cd assure360/test-app

# Get API URL
API_URL=$(cd infrastructure && terraform output -raw api_url)

# Run test suite
echo "Testing health endpoint..."
curl -f "$API_URL/health" && echo "✅ Health check passed"

echo "Testing hello endpoint..."
curl -f "$API_URL/hello" && echo "✅ Hello endpoint passed"

echo "Testing test endpoint..."
curl -f "$API_URL/test" && echo "✅ Test endpoint passed"

echo "🎉 All tests passed!"
```

## 🗂️ **Project Structure**

```
test-app/
├── app/                    # Python application
│   ├── app.py             # FastAPI application
│   ├── lambda_handler.py  # AWS Lambda entry point
│   ├── requirements.txt   # Python dependencies
│   └── Dockerfile         # Container configuration
├── infrastructure/         # Terraform infrastructure
│   ├── main.tf           # Main infrastructure code
│   ├── variables.tf      # Input variables
│   ├── outputs.tf        # Output values
│   └── versions.tf       # Provider versions
├── workflows/             # GitHub Actions workflows
│   └── deploy-test-app.yml # CI/CD pipeline
└── README.md             # This file
```

## 🔧 **Configuration**

### **Environment Variables:**
- `AWS_REGION` - AWS region (default: ap-southeast-2)
- `ENVIRONMENT` - App environment (production/development)

### **Terraform Variables:**
- `aws_region` - AWS region for resources
- `common_tags` - Tags applied to all resources

## 🧹 **Cleanup**

### **Destroy All Resources:**
```bash
# Navigate to the test-app directory
cd assure360/test-app

# Destroy infrastructure
cd infrastructure
terraform destroy
```

### **Manual ECR Cleanup:**
```bash
# Navigate to the test-app directory
cd assure360/test-app

# Clean up ECR images
aws ecr batch-delete-image --repository-name assure360-test-app --image-ids imageTag=latest
```

## 📊 **Monitoring**

### **CloudWatch Logs:**
```bash
# Navigate to the test-app directory
cd assure360/test-app

# View Lambda logs
aws logs tail /aws/lambda/assure360-test-app --follow
```

### **Lambda Metrics:**
- View in AWS Console → Lambda → assure360-test-app → Monitoring

### **API Gateway Metrics:**
- View in AWS Console → API Gateway → assure360-test-app-api → Monitoring

## 🚨 **Troubleshooting**

### **Common Issues:**

#### **1. Lambda Function Not Updating:**
```bash
# Check function status
aws lambda get-function --function-name assure360-test-app

# Force update
aws lambda update-function-code --function-name assure360-test-app --image-uri your-ecr-uri:latest
```

#### **2. API Gateway Not Responding:**
```bash
# Check API Gateway deployment
aws apigateway get-rest-api --rest-api-id your-api-id

# Check Lambda permissions
aws lambda get-policy --function-name assure360-test-app
```

#### **3. ECR Push Failing:**
```bash
# Re-authenticate with ECR
aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-southeast-2.amazonaws.com
```

## 🎉 **Success Criteria**

Your CI/CD pipeline is working correctly when:
- ✅ **GitHub Actions** shows all green checkmarks
- ✅ **API responds** to all test endpoints
- ✅ **Lambda function** shows "Active" status
- ✅ **API Gateway** shows deployed stage
- ✅ **No errors** in CloudWatch logs
- ✅ **Response times** under 1 second

## 🔗 **Related Documentation**

- [GitHub Actions OIDC Setup](../github-setup/README.md)
- [IAM Foundation](../iam-foundation/README.md)
- [Networking Configuration](../networking/README.md)

---

**This test app validates your entire CI/CD pipeline end-to-end!** 🚀
