#!/bin/bash

# Assure360 IAM Foundation Terraform Plan Script
# This script sets up the environment and runs terraform plan

echo "🚀 Starting Assure360 IAM Foundation Plan"

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

# Run Terraform plan
echo "📋 Running Terraform plan..."
terraform plan

echo "🎯 Plan complete! If it looks good, run: ./apply.sh"
