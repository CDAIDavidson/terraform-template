#!/bin/bash

# Assure360 Networking Terraform Apply Script
# This script sets up the environment and runs terraform apply

echo "🚀 Starting Assure360 Networking Apply"

# Load environment variables from .env file
echo "📁 Loading environment variables from .env file..."
if [ -f .env ]; then
    set -a; source ./.env; set +a
    echo "✅ Environment variables loaded from .env file"
else
    echo "⚠️  No .env file found, using default values"
fi

# Check AWS profile
echo "🔑 Checking AWS profile..."
if [ -n "$AWS_PROFILE" ]; then
    echo "✅ AWS profile set to: $AWS_PROFILE"
else
    echo "❌ No AWS profile specified!"
    echo "   Please set AWS_PROFILE before running this script:"
    echo "   export AWS_PROFILE=your-profile-name"
    exit 1
fi

# Verify environment variables are loaded
echo "✅ Configuration loaded:"
echo "   TF_VAR_region: ${TF_VAR_region:-ap-southeast-2 (default)}"
echo "   AWS_PROFILE: ${AWS_PROFILE:-default}"

# Run Terraform apply
echo "🚀 Running Terraform apply..."
terraform apply

echo "🎉 Apply complete! Networking stack created!"
echo ""
echo "📋 Next steps:"
echo "   1) Push your app image to ECR: ${TF_VAR_ecr_repo_url:-<set TF_VAR_ecr_repo_url>}"
echo "   2) Check ALB: terraform output alb_dns_name"
echo "   3) (Optional) create ACM DNS validation records for ${TF_VAR_domain_name:-example.yourdomain.com}"
