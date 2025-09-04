# Assure360 — Developer CLI Access

This Terraform root creates four developer IAM users, adds them to **davidson-developers**, and generates **programmatic access keys**.

## What This Does
Creates four IAM users with `davidson-` prefixed usernames, adds them to the existing `davidson-developers` group, and generates access keys for CLI access.

## Prereqs
- The IAM group **davidson-developers** already exists in this account and is attached to **PowerUserAccess** (per org standard).
- Your local AWS credentials target the new account (e.g., `AWS_PROFILE=<profile>`).

## Quick Commands

### Plan Script
```bash
cd assure360
chmod +x plan.sh
./plan.sh
```

### Apply Script
```bash
cd assure360
chmod +x apply.sh
./apply.sh
```

## Step-by-Step Instructions

### Step 1: Navigate to Directory
```bash
cd assure360
```

### Step 2: Configure Environment (Optional)
```bash
# Copy the example file
cp env.example .env

# Edit .env with your configuration (optional - defaults work)
# nano .env
```

### Step 3: Set AWS Profile
```bash
# Set to your target account profile
export AWS_PROFILE=your-aws-profile
```

### Step 4: Initialize Terraform
```bash
terraform init
```

### Step 5: Review Plan
```bash
chmod +x plan.sh
./plan.sh
```

### Step 6: Deploy
```bash
chmod +x apply.sh
./apply.sh
```

## What Gets Created

- **Four IAM Users**:
  - `davidson-alice.smith`
  - `davidson-bob.jones` 
  - `davidson-carol.ng`
  - `davidson-dan.lee`
- **Group Membership**: All users added to `davidson-developers` group
- **Access Keys**: One programmatic access key per user for CLI access
- **Tags**: Proper tagging with CostCenter, Team, Owner, and Role

## Retrieve Keys (Platform only — handle securely)
```bash
terraform -chdir=assure360 output -json developer_access_keys > /tmp/dev_keys.json
```

**Distribute each user's pair privately (password manager / encrypted message). Never paste secrets in chat or email.**

## Developer Setup Instructions

1. **Install AWS CLI v2.**

2. **Configure a profile:**
```bash
aws configure --profile davidson-dev
# Access Key ID: <provided securely>
# Secret Access Key: <provided securely>
# Default region: ap-southeast-2
# Output format: json
```

3. **Verify:**
```bash
AWS_PROFILE=davidson-dev aws sts get-caller-identity
```

4. **Use the profile:**
```bash
AWS_PROFILE=davidson-dev aws s3 ls
```

## Configuration Files

- **`main.tf`**: Core Terraform configuration for IAM users and group membership
- **`outputs.tf`**: Sensitive outputs for access keys
- **`versions.tf`**: Terraform and provider version constraints
- **`env.example`**: Environment variable template (copy to `.env` to customize)
- **`plan.sh`**: Shell script for running `terraform plan`
- **`apply.sh`**: Shell script for running `terraform apply`

## Notes

- Usernames are prefixed with `davidson-` to match conventions.
- If the `davidson-developers` group does not exist in this account, create it first (with PowerUserAccess) or update this root accordingly.
- Consider rotating keys periodically and migrating to AWS SSO when ready.
- The `.env` file is optional - defaults will work if the `davidson-developers` group exists.
