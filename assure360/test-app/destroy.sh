#!/bin/bash

# Assure360 Test App Destruction Script
# This script destroys all test app resources

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

# Confirm destruction
confirm_destruction() {
    print_warning "This will destroy ALL test app resources!"
    echo "This includes:"
    echo "  - Lambda function"
    echo "  - API Gateway"
    echo "  - ECR repository and images"
    echo "  - CloudWatch log groups"
    echo "  - IAM roles"
    echo ""
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_status "Destruction cancelled"
        exit 0
    fi
}

# Destroy infrastructure
destroy_infrastructure() {
    print_status "Destroying infrastructure..."
    
    cd infrastructure
    
    # Initialize Terraform if needed
    if [ ! -d ".terraform" ]; then
        print_status "Initializing Terraform..."
        terraform init
    fi
    
    # Destroy infrastructure
    print_status "Destroying resources..."
    terraform destroy -auto-approve
    
    print_success "Infrastructure destroyed successfully!"
    
    cd ..
}

# Clean up ECR images
cleanup_ecr() {
    print_status "Cleaning up ECR images..."
    
    # Try to delete images (may fail if repository doesn't exist)
    if aws ecr describe-repositories --repository-names assure360-test-app > /dev/null 2>&1; then
        print_status "Deleting ECR images..."
        aws ecr batch-delete-image \
            --repository-name assure360-test-app \
            --image-ids imageTag=latest || true
        
        print_success "ECR images cleaned up!"
    else
        print_status "ECR repository not found, skipping cleanup"
    fi
}

# Main function
main() {
    echo "🧹 Assure360 Test App Destruction"
    echo "================================="
    echo ""
    
    # Confirm destruction
    confirm_destruction
    
    # Destroy infrastructure
    destroy_infrastructure
    
    # Clean up ECR images
    cleanup_ecr
    
    # Show final info
    echo ""
    print_success "Cleanup complete!"
    echo ""
    echo "All test app resources have been destroyed:"
    echo "  ✅ Lambda function"
    echo "  ✅ API Gateway"
    echo "  ✅ ECR repository"
    echo "  ✅ CloudWatch log groups"
    echo "  ✅ IAM roles"
    echo ""
    echo "You can now safely delete this directory if desired."
}

# Run main function
main "$@"
