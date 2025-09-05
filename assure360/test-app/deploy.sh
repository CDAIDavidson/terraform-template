#!/bin/bash

# Assure360 Test App Deployment Script
# This script deploys the test app infrastructure and application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed!"
        echo "Please install it from: https://aws.amazon.com/cli/"
        exit 1
    fi
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed!"
        echo "Please install it from: https://www.docker.com/get-started"
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed!"
        echo "Please install it from: https://terraform.io/downloads"
        exit 1
    fi
    
    print_success "All prerequisites are installed"
}

# Deploy infrastructure
deploy_infrastructure() {
    print_status "Deploying infrastructure..."
    
    cd infrastructure
    
    # Initialize Terraform
    print_status "Initializing Terraform..."
    terraform init
    
    # Plan deployment
    print_status "Planning deployment..."
    terraform plan -out=tfplan
    
    # Apply deployment
    print_status "Applying deployment..."
    terraform apply -auto-approve tfplan
    
    # Get outputs
    ECR_REPOSITORY_URL=$(terraform output -raw ecr_repository_url)
    API_URL=$(terraform output -raw api_url)
    
    print_success "Infrastructure deployed successfully!"
    echo "  ECR Repository: $ECR_REPOSITORY_URL"
    echo "  API URL: $API_URL"
    
    cd ..
}

# Build and push Docker image
build_and_push_image() {
    print_status "Building and pushing Docker image..."
    
    cd app
    
    # Get ECR repository URL
    ECR_REPOSITORY_URL=$(cd ../infrastructure && terraform output -raw ecr_repository_url)
    
    # Login to ECR
    print_status "Logging in to ECR..."
    aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin $ECR_REPOSITORY_URL
    
    # Build image
    print_status "Building Docker image..."
    docker build -t assure360-test-app .
    docker tag assure360-test-app:latest $ECR_REPOSITORY_URL:latest
    
    # Push image
    print_status "Pushing image to ECR..."
    docker push $ECR_REPOSITORY_URL:latest
    
    print_success "Docker image built and pushed successfully!"
    
    cd ..
}

# Update Lambda function
update_lambda() {
    print_status "Updating Lambda function..."
    
    ECR_REPOSITORY_URL=$(cd infrastructure && terraform output -raw ecr_repository_url)
    
    # Update function code
    aws lambda update-function-code \
        --function-name assure360-test-app \
        --image-uri $ECR_REPOSITORY_URL:latest
    
    # Wait for update to complete
    print_status "Waiting for Lambda update to complete..."
    aws lambda wait function-updated --function-name assure360-test-app
    
    print_success "Lambda function updated successfully!"
}

# Test deployment
test_deployment() {
    print_status "Testing deployment..."
    
    API_URL=$(cd infrastructure && terraform output -raw api_url)
    
    # Test health endpoint
    print_status "Testing health endpoint..."
    if curl -f "$API_URL/health" > /dev/null 2>&1; then
        print_success "Health endpoint test passed"
    else
        print_error "Health endpoint test failed"
        return 1
    fi
    
    # Test hello endpoint
    print_status "Testing hello endpoint..."
    if curl -f "$API_URL/hello" > /dev/null 2>&1; then
        print_success "Hello endpoint test passed"
    else
        print_error "Hello endpoint test failed"
        return 1
    fi
    
    # Test test endpoint
    print_status "Testing test endpoint..."
    if curl -f "$API_URL/test" > /dev/null 2>&1; then
        print_success "Test endpoint test passed"
    else
        print_error "Test endpoint test failed"
        return 1
    fi
    
    print_success "All tests passed!"
}

# Main function
main() {
    echo "🚀 Assure360 Test App Deployment"
    echo "================================"
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Deploy infrastructure
    deploy_infrastructure
    
    # Build and push image
    build_and_push_image
    
    # Update Lambda function
    update_lambda
    
    # Test deployment
    test_deployment
    
    # Show final info
    echo ""
    echo "🎉 Deployment complete!"
    echo ""
    API_URL=$(cd infrastructure && terraform output -raw api_url)
    echo "API URL: $API_URL"
    echo ""
    echo "Test endpoints:"
    echo "  Health: $API_URL/health"
    echo "  Hello:  $API_URL/hello"
    echo "  Test:   $API_URL/test"
    echo "  Docs:   $API_URL/docs"
    echo ""
    echo "To test manually:"
    echo "  curl $API_URL/health"
    echo "  curl $API_URL/hello"
    echo "  curl $API_URL/test"
}

# Run main function
main "$@"
