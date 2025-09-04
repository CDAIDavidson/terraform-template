#!/bin/bash

# Assure360 Networking Terraform Plan Script
# This script sets up the environment and runs terraform plan

echo "🚀 Starting Assure360 Networking Plan"

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

# Set plan output file
PLAN_FILE="${1:-terraform-plan-$(date +%Y%m%d-%H%M%S).txt}"

# Run Terraform plan
echo "📋 Running Terraform plan..."
echo "📄 Plan output will be saved to: $PLAN_FILE"
terraform plan -out="$PLAN_FILE.plan" > "$PLAN_FILE" 2>&1

# Check if plan was successful
if [ $? -eq 0 ]; then
    echo "✅ Plan completed successfully!"
    echo "📄 Plan details saved to: $PLAN_FILE"
    echo "📦 Plan file saved to: $PLAN_FILE.plan"
    echo ""
    echo "To review the plan:"
    echo "  cat $PLAN_FILE"
    echo "  less $PLAN_FILE"
    echo ""
    echo "To apply the plan:"
    echo "  terraform apply $PLAN_FILE.plan"
    echo "  or run: ./apply.sh"
else
    echo "❌ Plan failed! Check the output in: $PLAN_FILE"
    exit 1
fi
