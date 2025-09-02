# AWS Multi-Account Management with Terraform

This repository provides **modular Terraform components** for managing AWS accounts, IAM users, and secrets in a multi-account organization.

## Architecture Overview

The solution uses a modular approach with separate components that can be used independently or together:

```
┌─────────────────────────────────────────────────────────────────┐
│                    Management Account                           │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Account Module                              │   │
│  │  • Create AWS account in organization                   │   │
│  │  • Simple, clean configuration                          │   │
│  │  • Output account ID and ARN                            │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Account ID
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Member Account                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Users Module                               │   │
│  │  • Assume bootstrap role                                │   │
│  │  • Create IAM users with appropriate rights             │   │
│  │  • Generate access keys + console access                │   │
│  └─────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Parameter Store Module                     │   │
│  │  • Create KMS keys for encryption                       │   │
│  │  • Store service credentials securely                   │   │
│  │  • Configure IAM policies for access                    │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
terraform/
├── account/                      # Account Management Module
│   ├── main.tf                   # Creates AWS account in organization
│   ├── variables.tf              # Essential variables (name, email, OU)
│   ├── outputs.tf                # Account ID and ARN outputs
│   ├── versions.tf               # Terraform and provider versions
│   ├── env.example               # Configuration template
│   ├── plan.sh                   # Planning script
│   ├── apply.sh                  # Deployment script
│   └── README.md                 # Module documentation
│
├── users/                        # IAM User Management Module
│   ├── main.tf                   # IAM users, access keys, login profiles
│   ├── variables.tf              # User configuration options
│   ├── outputs.tf                # User details and console access
│   ├── versions.tf               # Terraform and provider versions
│   ├── env.example               # Configuration template
│   ├── plan.sh                   # Planning script
│   ├── apply.sh                  # Deployment script
│   └── README.md                 # Module documentation
│
├── parameter-store/              # Secrets Management Module
│   ├── main.tf                   # Parameter Store, KMS keys, IAM policies
│   ├── variables.tf              # Secrets configuration
│   ├── outputs.tf                # Parameter details and usage instructions
│   ├── versions.tf               # Terraform and provider versions
│   ├── env.example               # Configuration template
│   ├── plan.sh                   # Planning script
│   ├── apply.sh                  # Deployment script
│   ├── run-terraform.sh          # Alternative deployment script
│   └── README.md                 # Module documentation
│
└── README.md                     # This file - overall documentation
```

## Prerequisites

1. **AWS Organizations**: Your AWS account must be part of an organization
2. **Terraform**: Version 1.0 or later
3. **AWS CLI**: Configured with appropriate credentials
4. **Permissions**: 
   - Account module: Organizations management permissions
   - Users module: Ability to assume the bootstrap role
   - Parameter Store module: Access to the target account

## Quick Start

### Option 1: Complete Setup (All Modules)

```bash
# 1. Create Account
cd account
export AWS_PROFILE=your-aws-profile
cp env.example .env
# Edit .env with your configuration
terraform init && terraform apply
export NEW_ACCOUNT_ID=$(terraform output -raw new_account_id)

# 2. Create Users
cd ../users
cp env.example .env
# Edit .env with your configuration
terraform init && terraform apply -var="member_account_id=$NEW_ACCOUNT_ID"

# 3. Create Parameter Store
cd ../parameter-store
cp env.example .env
# Edit .env with your configuration
terraform init && terraform apply -var="member_account_id=$NEW_ACCOUNT_ID"
```

### Option 2: Individual Module Usage

Each module can be used independently:

```bash
# Use only the account module
cd account
cp env.example .env
# Configure and deploy
terraform init && terraform apply

# Use only the users module (requires existing account)
cd users
cp env.example .env
# Configure with existing account ID
terraform init && terraform apply

# Use only the parameter store module (requires existing account and users)
cd parameter-store
cp env.example .env
# Configure with existing account ID
terraform init && terraform apply
```

## What Gets Created

### Account Module
- ✅ **AWS Account**: Named "YOUR_PROJECT" with email "your-email@yourdomain.com"
- ✅ **Organization Integration**: Placed in specified OU
- ✅ **Bootstrap Role**: `OrganizationAccountAccessRole` automatically created

### Users Module
- ✅ **IAM Users**: Developer, admin, and monitor users with appropriate access levels
- ✅ **Access Keys**: For programmatic access (AWS CLI, SDKs)
- ✅ **Console Access**: Login profiles with secure passwords
- ✅ **Permissions**: Configurable policies (AdministratorAccess, ReadOnlyAccess)

### Parameter Store Module
- ✅ **KMS Key**: Custom encryption key for Parameter Store
- ✅ **Parameter Store Items**: Service credentials and configuration
- ✅ **IAM Policy**: Least-privilege access to Parameter Store
- ✅ **Security**: All sensitive parameters encrypted with KMS

## Modular Benefits

### Separation of Concerns
- **Account Module**: Organization-level resources (accounts only)
- **Users Module**: Account-specific resources (users, policies)
- **Parameter Store Module**: Application configuration (secrets, credentials)

### Dependency Management
- Users module requires account module completion
- Parameter Store module requires users module completion
- Clear resource ownership and lifecycle

### Security
- Bootstrap role provides controlled cross-account access
- No need to share root credentials
- Audit trail for all operations

### Flexibility
- Each module can be used independently
- Modules can be run multiple times to update resources
- Easy to modify users and parameters without recreating accounts
- Can be integrated into CI/CD pipelines
- Easy to add new modules (networking, databases, etc.)

## Important Notes

### Account Creation Speed
- **Expected time**: 5-10 minutes for account creation
- **Actual time**: Can be as fast as 13 seconds if organization is well-established
- **Verification**: Use `aws sts assume-role` to test bootstrap role access

### Provider Configuration
- **Account Module**: Uses default AWS provider (management account)
- **Users Module**: Uses aliased provider `aws.new` (member account via bootstrap role)
- **Parameter Store Module**: Uses aliased provider `aws.member` (member account via bootstrap role)
- **Critical**: All IAM resources in Users and Parameter Store modules must use the appropriate aliased provider

### Bootstrap Role
- **Name**: `OrganizationAccountAccessRole` (AWS Organizations standard)
- **Permissions**: Full access to member account
- **Trust Policy**: Allows management account to assume

## Security Features

1. **Bootstrap Role**: Uses AWS Organizations standard role
2. **Least Privilege**: User gets AdministratorAccess (configurable)
3. **Console Security**: Password reset required on first login
4. **Access Keys**: Secure generation and management
5. **Cross-Account**: Controlled access via role assumption

## Best Practices

### Account Module
- Use descriptive account names and emails
- Keep configuration simple and focused
- Verify account creation in AWS Organizations console

### Users Module
- Always use `provider = aws.new` for member account resources
- Test bootstrap role assumption before applying
- Use `data "aws_caller_identity"` to verify correct account

### Parameter Store Module
- Always use `provider = aws.member` for member account resources
- Ensure users exist before creating parameter store access policies
- Test parameter access after deployment

### General
- Use version control for all Terraform code
- Test in non-production environments first
- Monitor account and user activities

## Troubleshooting

### Common Issues

1. **Provider Configuration Errors**
   - Ensure no duplicate provider definitions
   - Check that all IAM resources use `aws.new` provider
   - Verify `terraform providers` shows correct configuration

2. **Role Assumption Failed**
   - Verify bootstrap role exists in member account
   - Check that your credentials have permission to assume the role
   - Ensure the account ID is correct

3. **Account Creation Issues**
   - Check AWS Organizations console for account status
   - Verify email uniqueness across all AWS accounts
   - Wait for account provisioning to complete

### Verification Steps

1. **Test Bootstrap Role**:
   ```bash
   aws sts assume-role \
     --role-arn "arn:aws:iam::<ACCOUNT_ID>:role/OrganizationAccountAccessRole" \
     --role-session-name "test" \
     --profile your-aws-profile
   ```

2. **Check Provider Configuration**:
   ```bash
   terraform providers
   ```

3. **Verify Account Identity**:
   ```bash
   terraform output member_caller_identity
   ```

## Example Workflows

### Complete Setup Workflow

```bash
# 1. Create account
cd account
export AWS_PROFILE=your-aws-profile
cp env.example .env
# Edit .env with your configuration
terraform init && terraform apply
export NEW_ACCOUNT_ID=$(terraform output -raw new_account_id)

# 2. Create users
cd ../users
cp env.example .env
# Edit .env with your configuration
terraform init && terraform apply -var="member_account_id=$NEW_ACCOUNT_ID"

# Get user details
terraform output developer_user
terraform output console_login

# 3. Create Parameter Store items
cd ../parameter-store
cp env.example .env
# Edit .env with your actual client/secret keys
terraform init && terraform apply -var="member_account_id=$NEW_ACCOUNT_ID"

# Get parameter details
terraform output parameter_names
terraform output usage_instructions
```

### Individual Module Workflow

```bash
# Use only the users module with existing account
cd users
cp env.example .env
# Edit .env with existing account ID
terraform init && terraform apply

# Use only the parameter store module with existing account
cd parameter-store
cp env.example .env
# Edit .env with existing account ID
terraform init && terraform apply
```

## Next Steps

After deploying the modules:
1. Distribute access keys securely to team members
2. Share console login credentials
3. Configure your applications to use Parameter Store
4. Set up monitoring and alerting for the new account
5. Configure additional security controls as needed
6. Implement credential rotation procedures
7. Consider adding additional modules (networking, databases, etc.)

## Setting Up Access

### 1. AWS CLI Profile Setup

Create a new AWS CLI profile for the member account using the access keys from Stage 2:

```bash
# Get the access keys from Stage 2 outputs
cd users
terraform output developer_user

# Configure AWS CLI profile for the new account
terraform output developer_user
aws configure --profile your-aws-profile


# Enter the following when prompted:
# AWS Access Key ID: [from terraform output]
# AWS Secret Access Key: [from terraform output]
# Default region name: ap-southeast-2
# Default output format: json
```

**Test the profile:**
```bash
# Verify you're in the correct account
aws sts get-caller-identity --profile your-aws-profile

# Should show your account ID
```

### 2. Console Login

Access the AWS Management Console for the member account:

```bash
# Get console login details
terraform output console_login

# If password shows as <sensitive>, get the actual value:
terraform output -raw console_login
# Or for just the password:
terraform output -raw console_login | jq -r '.password'
```

**Console URL**: https://YOUR_ACCOUNT_ID.signin.aws.amazon.com/console
**Username**: your-dev-user
**Password**: [use terraform output -raw to see actual value]

**First-time login process:**
1. Navigate to the console URL
2. Enter username: `your-dev-user`
3. Enter the generated password (use `terraform output -raw console_login`)
4. **Important**: You'll be prompted to change the password on first login
5. Choose a new secure password

### 3. Verify Access

**CLI Access:**
```bash
# List S3 buckets (should work with admin access)
aws s3 ls --profile your-aws-profile

# Check IAM users
aws iam list-users --profile your-aws-profile
```

**Console Access:**
- Navigate to different AWS services
- Verify you have full administrator access
- Check that you're in the correct account (YOUR_PROJECT)

### 4. Profile Usage Examples

```bash
# Use the profile for all AWS CLI commands
aws s3 ls --profile your-aws-profile
aws ec2 describe-instances --profile your-aws-profile
aws iam get-user --profile your-aws-profile

# Set as default for current session
export AWS_PROFILE=your-aws-profile
aws s3 ls  # No need to specify --profile
```

**Note**: Keep the access keys secure and rotate them regularly according to your organization's security policies.

## Contributing

1. Follow the existing code structure
2. Keep configurations simple and focused
3. Test changes in a safe environment
4. Update README files as needed

## License

This project is provided as-is for educational and operational purposes. Please ensure compliance with your organization's security policies and AWS best practices.
