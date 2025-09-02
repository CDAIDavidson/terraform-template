#!/bin/bash

# Stage 1: Account Creation Terraform Plan Script
# This script sets up the environment and runs terraform plan

echo "🚀 Starting Stage 1: Account Creation Plan"

# Load environment variables from .env file
echo "📁 Loading environment variables from .env file..."
set -a; source ./.env; set +a

# Set AWS profile for management account
echo "🔑 Setting AWS profile to management account..."
export AWS_PROFILE=your-aws-profile

# Verify environment variables are loaded
echo "✅ Environment variables loaded:"
echo "   TF_VAR_account_name: $TF_VAR_account_name"
echo "   TF_VAR_account_email: $TF_VAR_account_email"
echo "   TF_VAR_parent_ou_id: $TF_VAR_parent_ou_id"

# Run Terraform plan
echo "📋 Running Terraform plan..."
terraform plan

echo "🎯 Plan complete! If it looks good, run: ./apply.sh"
