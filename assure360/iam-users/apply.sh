#!/bin/bash

# Assure360 Developer Access Terraform Apply Script
# This script sets up the environment and runs terraform apply

echo "🚀 Starting Assure360 Developer Access Apply"

# Load environment variables from .env file
echo "📁 Loading environment variables from .env file..."
if [ -f .env ]; then
    set -a; source ./.env; set +a
    echo "✅ Environment variables loaded from .env file"
else
    echo "⚠️  No .env file found, using default values"
fi

# Set AWS profile
echo "🔑 Setting AWS profile..."
if [ -n "$TF_VAR_aws_profile" ]; then
    export AWS_PROFILE=$TF_VAR_aws_profile
    echo "✅ AWS profile set to: $AWS_PROFILE"
else
    echo "⚠️  No AWS profile specified, using default"
fi

# Verify environment variables are loaded
echo "✅ Configuration loaded:"
echo "   TF_VAR_region: ${TF_VAR_region:-ap-southeast-2 (default)}"
echo "   AWS_PROFILE: ${AWS_PROFILE:-default}"

# Run Terraform apply
echo "🚀 Running Terraform apply..."
terraform apply

echo "🎉 Apply complete! Your developer access keys are now created!"
echo ""
echo "📋 To retrieve the access keys (handle securely):"
echo "   terraform output -json developer_access_keys > /tmp/dev_keys.json"
echo ""
echo "⚠️  Remember to distribute the access keys securely to each developer!"
