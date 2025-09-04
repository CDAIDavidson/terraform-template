#!/bin/bash

# Assure360 IAM Foundation Terraform Apply Script
# This script sets up the environment and runs terraform apply

echo "🚀 Starting Assure360 IAM Foundation Apply"

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
if [ -n "$AWS_PROFILE" ]; then
    echo "✅ AWS profile set to: $AWS_PROFILE"
elif [ -n "$TF_VAR_aws_profile" ]; then
    export AWS_PROFILE=$TF_VAR_aws_profile
    echo "✅ AWS profile set to: $AWS_PROFILE"
else
    echo "❌ No AWS profile specified!"
    echo "   Please set AWS_PROFILE before running this script:"
    echo "   export AWS_PROFILE=AdminAssure360"
    echo "   or add TF_VAR_aws_profile=\"AdminAssure360\" to your .env file"
    exit 1
fi

# Verify environment variables are loaded
echo "✅ Configuration loaded:"
echo "   TF_VAR_region: ${TF_VAR_region:-ap-southeast-2 (default)}"
echo "   AWS_PROFILE: ${AWS_PROFILE:-default}"

# Run Terraform apply
echo "🚀 Running Terraform apply..."
terraform apply

echo "🎉 Apply complete! Prerequisites are now created!"
echo ""
echo "📋 Next steps:"
echo "   1. Verify the group and policies were created:"
echo "      aws iam get-group --group-name davidson-developers"
echo "   2. Run the create-users module:"
echo "      cd ../create-users && terraform init && terraform apply"
echo ""
echo "⚠️  Remember to run the create-users module to add the four developers!"
