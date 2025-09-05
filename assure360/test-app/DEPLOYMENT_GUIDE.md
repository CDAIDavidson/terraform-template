# 🚀 Test App Deployment Guide

## **What We Built**

A complete serverless Python test application that validates your GitHub Actions CI/CD pipeline:

### **📁 Project Structure**
```
test-app/
├── app/                    # Python FastAPI application
│   ├── app.py             # Main application with 7 endpoints
│   ├── lambda_handler.py  # AWS Lambda entry point
│   ├── requirements.txt   # Python dependencies
│   └── Dockerfile         # Container configuration
├── infrastructure/         # Terraform infrastructure
│   ├── main.tf           # AWS resources (Lambda, API Gateway, ECR)
│   ├── variables.tf      # Configuration variables
│   ├── outputs.tf        # API URLs and resource info
│   └── versions.tf       # Provider versions
├── workflows/             # GitHub Actions CI/CD
│   └── deploy-test-app.yml # Complete deployment pipeline
├── deploy.sh             # Manual deployment script
├── destroy.sh            # Cleanup script
├── test.sh              # Testing script
├── run-local.sh         # Local development script
└── README.md            # Complete documentation
```

## **🎯 What This Tests**

### **GitHub Actions OIDC:**
- ✅ **Authentication** - Uses your AWS role ARNs
- ✅ **Permissions** - ECR, Lambda, API Gateway access
- ✅ **Security** - No hardcoded credentials

### **AWS Resources:**
- ✅ **ECR Repository** - Docker image storage
- ✅ **Lambda Function** - Serverless Python runtime
- ✅ **API Gateway** - Public HTTP endpoints
- ✅ **CloudWatch Logs** - Application monitoring
- ✅ **IAM Roles** - Least privilege access

### **CI/CD Pipeline:**
- ✅ **Build** - Docker image creation
- ✅ **Deploy** - Infrastructure and application
- ✅ **Test** - Automated endpoint validation
- ✅ **Monitor** - Health checks and logging

## **🚀 Quick Start**

### **1. Deploy Everything:**
```bash
cd test-app
./deploy.sh
```

### **2. Test the API:**
```bash
./test.sh
```

### **3. Run Locally:**
```bash
./run-local.sh
```

### **4. Clean Up:**
```bash
./destroy.sh
```

## **📡 API Endpoints**

| Endpoint | Description | Example |
|----------|-------------|---------|
| `/health` | Health check | `curl $API_URL/health` |
| `/hello` | Hello world | `curl $API_URL/hello?name=Chris` |
| `/time` | Current time | `curl $API_URL/time` |
| `/status` | App status | `curl $API_URL/status` |
| `/info` | App info | `curl $API_URL/info` |
| `/test` | CI/CD test | `curl $API_URL/test` |
| `/docs` | API docs | Open in browser |

## **🔄 CI/CD Workflow**

### **Automatic Triggers:**
- **Push to `main`** → Deploy to production
- **Push to `dev`** → Deploy to development  
- **Pull Request** → Run tests only

### **Manual Actions:**
- **Destroy Resources** → Clean up everything
- **Redeploy** → Force new deployment

## **✅ Success Criteria**

Your CI/CD is working when:
- ✅ **GitHub Actions** shows green checkmarks
- ✅ **API responds** to all test endpoints
- ✅ **Lambda function** shows "Active" status
- ✅ **No errors** in CloudWatch logs
- ✅ **Response times** under 1 second

## **🧪 Testing Strategy**

### **Automated Tests:**
- Health endpoint validation
- Hello endpoint with parameters
- Error handling (404 responses)
- Response time checks

### **Manual Tests:**
- Browser access to API docs
- curl commands for all endpoints
- CloudWatch log monitoring
- AWS Console verification

## **🔧 Configuration**

### **Environment Variables:**
- `AWS_REGION` - AWS region (ap-southeast-2)
- `ENVIRONMENT` - App environment (production/development)

### **GitHub Secrets Required:**
- `AWS_ROLE_ARN_DEV` - Development role ARN
- `AWS_ROLE_ARN_PROD` - Production role ARN

## **📊 Monitoring**

### **CloudWatch Logs:**
```bash
aws logs tail /aws/lambda/assure360-test-app --follow
```

### **API Gateway Metrics:**
- Request count
- Response times
- Error rates
- 4xx/5xx status codes

## **🚨 Troubleshooting**

### **Common Issues:**

#### **1. Lambda Not Updating:**
```bash
aws lambda update-function-code --function-name assure360-test-app --image-uri your-ecr-uri:latest
```

#### **2. API Gateway Not Responding:**
```bash
aws apigateway get-rest-api --rest-api-id your-api-id
```

#### **3. ECR Push Failing:**
```bash
aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-southeast-2.amazonaws.com
```

## **🎉 What This Proves**

This test app validates that your entire CI/CD pipeline is working:

1. **GitHub Actions** can authenticate to AWS using OIDC
2. **Docker images** can be built and pushed to ECR
3. **Lambda functions** can be deployed and updated
4. **API Gateway** can serve HTTP requests
5. **End-to-end testing** works automatically
6. **Infrastructure as Code** is properly configured

## **🔗 Next Steps**

After successful testing:
1. **Keep the test app** for future CI/CD validation
2. **Use the patterns** for real applications
3. **Extend the infrastructure** as needed
4. **Add more test cases** for comprehensive validation

---

**This test app is your CI/CD validation tool!** 🎯
