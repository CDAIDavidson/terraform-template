#!/bin/bash

# Account Creation Terraform Plan Script
# This script sets up the environment and runs terraform plan

set -e  # Exit on any error

echo "🚀 Starting Account Creation Plan"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found. Please copy env.example to .env and configure it."
    echo "   cp env.example .env"
    echo "   # Then edit .env with your actual values"
    exit 1
fi

# Load environment variables from .env file
echo "📁 Loading environment variables from .env file..."
set -a; source ./.env; set +a

# Set AWS profile (use environment variable or default)
export AWS_PROFILE=${AWS_PROFILE:-"default"}

# Verify environment variables are loaded
echo "✅ Environment variables loaded:"
echo "   TF_VAR_account_name: $TF_VAR_account_name"
echo "   TF_VAR_account_email: $TF_VAR_account_email"
echo "   TF_VAR_parent_ou_id: $TF_VAR_parent_ou_id"
echo "   AWS_PROFILE: $AWS_PROFILE"

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo "🔧 Initializing Terraform..."
    terraform init
fi

# Run Terraform plan
echo "📋 Running Terraform plan..."
terraform plan

echo "🎯 Plan complete! If it looks good, run: ./apply.sh"
