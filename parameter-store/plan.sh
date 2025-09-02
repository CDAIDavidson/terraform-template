#!/bin/bash

# Stage 3: Parameter Store Terraform Plan Script
# This script sets up the environment and runs terraform plan

echo "🚀 Starting Stage 3: Parameter Store Plan"

# Prevent MSYS from converting TF_VAR_parameter_prefix to Windows paths
export MSYS2_ENV_CONV_EXCL='TF_VAR_parameter_prefix'

# Load environment variables from .env file
echo "📁 Loading environment variables from .env file..."
set -a; source ./.env; set +a

# Set AWS profile for management account
echo "🔑 Setting AWS profile to management account..."
export AWS_PROFILE=your-aws-profile

# Verify environment variables are loaded
echo "✅ Environment variables loaded:"
echo "   TF_VAR_parameter_prefix: $TF_VAR_parameter_prefix"
echo "   TF_VAR_member_account_id: $TF_VAR_member_account_id"
echo "   TF_VAR_environment: $TF_VAR_environment"

# Run Terraform plan
echo "📋 Running Terraform plan..."
terraform plan

echo "🎯 Plan complete! If it looks good, run: ./apply.sh"
