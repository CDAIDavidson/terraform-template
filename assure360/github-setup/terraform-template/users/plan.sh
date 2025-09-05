#!/bin/bash

# Stage 2: User Creation Terraform Plan Script
# This script sets up the environment and runs terraform plan

echo "🚀 Starting Stage 2: User Creation Plan"

# Load environment variables from .env file
echo "📁 Loading environment variables from .env file..."
set -a; source ./.env; set +a

# Set AWS profile for management account
echo "🔑 Setting AWS profile to management account..."
export AWS_PROFILE=your-aws-profile

# Verify environment variables are loaded
echo "✅ Environment variables loaded:"
echo "   TF_VAR_member_account_id: $TF_VAR_member_account_id"
echo "   TF_VAR_management_region: $TF_VAR_management_region"
echo "   TF_VAR_new_account_region: $TF_VAR_new_account_region"
echo "   TF_VAR_bootstrap_role_name: $TF_VAR_bootstrap_role_name"

# Run Terraform plan
echo "📋 Running Terraform plan..."
terraform plan

echo "🎯 Plan complete! If it looks good, run: ./apply.sh"
