



#  Create Parameter Store Items

## What This Does
Creates secure Parameter Store items in your member account to store service credentials (Service A, Service B, Service C, etc.) as encrypted JSON objects.

## Prerequisites
- ✅ Stage 1 completed (account created)
- ✅ Stage 2 completed (users created)
- ✅ Account ID from Stage 1 outputs

## Quick Commands

### Plan Script
```bash
cd parameter-store
chmod +x plan.sh
./plan.sh
```

### Apply Script
```bash
cd parameter-store
chmod +x apply.sh
./apply.sh
```

## Step-by-Step Instructions

### Step 1: Navigate to Directory
```bash
cd parameter-store
```

### Step 2: Add variabels to Your .env File
```bash
# Copy the example file


**Bash:**
```bash
set -a; source ./.env; set +a
```

### Step 4: Set AWS Profile
```bash
# Set to your management account profile
export AWS_PROFILE=your-aws-profile
```

### Step 5: Initialize Terraform
```bash
terraform init
```

### Step 6: Review Plan
```bash
chmod +x plan.sh
./plan.sh
```

### Step 7: Deploy
```bash
chmod +x apply.sh
./apply.sh
```

### Step 8: Verify Deployment
```bash
# Check outputs
terraform output

# Test parameter access (set to member account profile)
export AWS_PROFILE=your-aws-profile
aws ssm get-parameter --name "/keys/service_a" --with-decryption
```

## What Gets Created

- **KMS Key**: Custom encryption key for Parameter Store
- **IAM Policy**: `ParameterStoreAccess` attached to your developer user
- **Parameter Store Items**:
  - `/keys/service_a` (encrypted JSON)
  - `/keys/service_b_store1` (encrypted JSON)
  - `/keys/service_b_store2` (encrypted JSON)
  - `/keys/service_c` (encrypted JSON)
  - `/keys/environment` (unencrypted string)

## How to Use Your Parameters

### AWS CLI
```bash
# Set profile to member account
export AWS_PROFILE=your-aws-profile

# Get credentials
aws ssm get-parameter --name "/keys/service_a" --with-decryption
aws ssm get-parameter --name "/keys/service_b_store1" --with-decryption
aws ssm get-parameter --name "/keys/service_c" --with-decryption

# List all parameters
aws ssm get-parameters-by-path --path "/keys" --recursive --with-decryption
```

### In Your Applications
```python
import boto3
import json

def get_credentials(service_name):
    ssm = boto3.client('ssm')
    response = ssm.get_parameter(
        Name=f'/keys/{service_name}',
        WithDecryption=True
    )
    return json.loads(response['Parameter']['Value'])

# Usage
service_a_creds = get_credentials('service_a')
print(f"Access Key: {service_a_creds['access_key']}")
```

## .env File Configuration

Copy `env.example` to `.env` and update these key variables:

- `TF_VAR_member_account_id` - Your account ID from Stage 1
- `TF_VAR_secrets` - JSON with your service credentials
- `TF_VAR_aws_profile` - Your AWS profile name
- `TF_VAR_parameter_prefix` - Parameter path prefix (default: `/keys`)

## Troubleshooting

**Access Denied?**
```bash
# Check your profile
aws sts get-caller-identity --profile your-aws-profile
```

**Parameter Not Found?**
```bash
# List all parameters
aws ssm describe-parameters --profile your-aws-profile

# Check specific parameter
aws ssm get-parameter --name "/keys/service_a" --profile your-aws-profile
```

**Can't Decrypt?**
```bash
# Check KMS key
aws kms describe-key --key-id alias/parameter-store-key --profile your-aws-profile
```

## Security Notes

- ✅ Never commit `.env` with real credentials
- ✅ All sensitive parameters are encrypted with KMS
- ✅ Only your developer user has access
- ✅ All access is logged via CloudTrail


