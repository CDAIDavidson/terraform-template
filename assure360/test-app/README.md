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

## 🧪 Run GitHub Actions locally with nektos/act

**Short version:** `nektos/act` lets you run your GitHub Actions locally in Docker so you can reproduce failing CI jobs, iterate fast, and inspect everything (env, logs, artifacts) without pushing commits. See the docs: [nektos/act](https://github.com/nektos/act)

### What `act` is good for
- **Reproduce failures locally**: Run the same workflow/job that’s failing on GitHub, but on your machine, enabling fast tweak → run → logs loops.
- **Trigger the exact event**: Supply a custom event payload (pull_request, tags, workflow_dispatch inputs) so `github.event.*` resolves exactly as in CI.
- **Select jobs & matrices**: Run only the failing job or a single matrix combo to focus your debugging.
- **Provide vars & secrets**: Pass repo/environment variables and secrets (including `GITHUB_TOKEN`/PAT) so API calls and private fetches work locally.
- **Inspect artifacts**: Start a local artifact server so `upload-artifact`/`download-artifact` work.
- **Match runner images**: Map `ubuntu-*` to fuller images that resemble GitHub’s hosted runners.

### Fast path: reproduce a failing job
From your repo root:

```bash
# 0) Install act (examples)
# macOS (Homebrew)
brew install act
# Windows (Scoop)
scoop install act
# Windows (Chocolatey)
choco install act

# 1) (Optional) Set useful defaults in .actrc
cat > .actrc <<'RC'
-P ubuntu-latest=catthehacker/ubuntu:full-latest
--action-offline-mode
--container-architecture=linux/amd64
--artifact-server-path=.artifacts
RC

# 2) See what will run on the PR event and pick the failing job
act -l pull_request

# 3) Provide the exact event payload (refs, inputs, tags, etc.)
cat > event.json <<'JSON'
{ "pull_request": { "head": { "ref": "feature-branch" }, "base": { "ref": "main" } } }
JSON

# 4) Run only the failing job
act pull_request -j build-and-deploy  -e event.json \
  --var-file .vars --secret-file .secrets
```

- `-l` lists jobs per event.
- `-j` runs a single job.
- `-e` supplies event JSON (critical for `github.event.*`).
- `--var-file/--secret-file` read `.env`-style files for `${{ vars.* }}` and `${{ secrets.* }}`.
- If your workflow is in a nonstandard path, add `-W .github/workflows/your.yml`.

### Debugging tricks that save hours
- **Run one matrix combo** (e.g., Node 18):
  ```bash
  act push --matrix node:18 -j build
  ```
- **Skip nonessential steps locally**: `act` sets `env.ACT=true`. Use `if: ${{ !env.ACT }}` on steps like Slack/release publishing.
- **Simulate workflow_dispatch inputs**:
  ```bash
  cat > payload.json <<'JSON'
  { "inputs": { "NAME": "Local Run", "SOME_VALUE": "123" } }
  JSON
  act workflow_dispatch -e payload.json
  ```
- **Artifacts for inspection**: With `--artifact-server-path=.artifacts`, `actions/upload-artifact` works and outputs land under `./.artifacts/`.
- **Match runner environment** more closely:
  ```bash
  act -P ubuntu-22.04=catthehacker/ubuntu:full-22.04
  # or
  act -P ubuntu-22.04=nektos/act-environments-ubuntu:22.04
  ```

### Common causes of “works in CI, fails in act” (and fixes)
- **Missing tools on the image**: Use a fuller image via `-P …` or install prerequisites in a setup step.
- **`GITHUB_TOKEN`/PAT required**: Supply `-s GITHUB_TOKEN` or `--secret-file`.
- **Artifacts not available**: Start the artifact server with `--artifact-server-path`.
- **Event-dependent logic**: Provide `-e event.json` (e.g., PR head/base, tags, inputs).
- **Matrix-only failures**: Narrow with `--matrix key:value`.

### Known limitations
- **Containers ≠ GitHub VMs**: Some services (e.g., systemd) won’t behave identically. Prefer fuller images when needed.
- **Windows/macOS parity**: No official Windows/macOS Docker images; running directly on host differs from GitHub’s VMs.
- **Not 100% feature parity**: A few contexts/features have caveats; plan to work around locally.

### Simple checklist for a failing build
1. `act -l <event>` → identify the job.
2. Create `event.json` with exact refs/inputs.
3. Add `.actrc` mapping runner images and enabling artifacts.
4. Run only the failing job: `act <event> -j <job> -e event.json`.
5. Pass secrets/vars: `--secret-file .secrets --var-file .vars`.
6. Inspect logs/artifacts locally; iterate until green.

If you tell us the failing job name and include the workflow snippet, we can tailor the exact `act` command and a minimal `event.json` to mirror your scenario.

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
