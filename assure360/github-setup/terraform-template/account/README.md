# Account Creation Module

This module creates a new AWS account within an AWS Organization. It's designed to be simple, focused, and secure.

## Overview

The Account Creation Module handles:
- ✅ **AWS Account Creation**: Creates a new account in your AWS Organization
- ✅ **Organization Integration**: Places the account in the specified Organizational Unit (OU)
- ✅ **Bootstrap Role**: Automatically creates the `OrganizationAccountAccessRole` for cross-account access
- ✅ **Security**: Prevents accidental account deletion with lifecycle rules
- ✅ **Validation**: Input validation for email format, OU ID format, and other parameters

## Prerequisites

1. **AWS Organizations**: Your AWS account must be part of an organization
2. **Terraform**: Version 1.0 or later
3. **AWS CLI**: Configured with appropriate credentials
4. **Permissions**: Organizations management permissions in the management account

## Quick Start

### 1. Configure Environment

```bash
# Copy the example configuration
cp env.example .env

# Edit .env with your actual values
nano .env  # or use your preferred editor
```

### 2. Update Required Variables in .env

**MUST CONFIGURE (Required):**
```bash
# Account Configuration - REQUIRED
TF_VAR_account_name="YourProjectName"           # 1-50 characters, alphanumeric
TF_VAR_account_email="your-email@domain.com"   # Must be unique across all AWS accounts
```

**OPTIONAL (Configure as needed):**
```bash
# Organization Settings
TF_VAR_parent_ou_id="ou-xxxxxxxxx-xxxxxxxxx"   # Leave empty for root OU
TF_VAR_iam_user_access_to_billing="DENY"       # "ALLOW" or "DENY"

# AWS Configuration
AWS_PROFILE="your-aws-profile"                 # Your AWS profile name
AWS_REGION="us-east-1"                         # AWS region

# Tags (JSON format)
TF_VAR_tags='{"Environment": "production", "Owner": "your-team", "Project": "YourProject"}'
```

### 3. Prerequisites Checklist

Before running the build, ensure you have:

- [ ] **AWS Organizations**: Your AWS account is part of an organization
- [ ] **AWS CLI**: Configured with appropriate credentials
- [ ] **Terraform**: Version 1.0 or later installed
- [ ] **Permissions**: Organizations management permissions in the management account
- [ ] **Unique Email**: The email address hasn't been used for any AWS account
- [ ] **Valid OU ID**: If using `parent_ou_id`, it must be in format `ou-xxxxxxxxx-xxxxxxxxx`

### 4. Deploy

```bash
# Plan the deployment (review what will be created)
./plan.sh

# Apply the changes (create the account)
./apply.sh
```

### 5. Get Account Information

```bash
# Get the new account ID
terraform output account_id

# Get the bootstrap role ARN
terraform output bootstrap_role_arn

# Check account status (should be "ACTIVE")
terraform output account_status
```

### 6. Validation Steps

After deployment, verify the account was created successfully:

```bash
# Test bootstrap role access
aws sts assume-role \
  --role-arn "$(terraform output -raw bootstrap_role_arn)" \
  --role-session-name "test" \
  --profile your-aws-profile

# Check AWS Organizations console
# - Navigate to AWS Organizations console
# - Verify the account appears in the correct OU
# - Check account status is "Active"
```

### 7. Important Notes

- **Account Creation Time**: Can take 5-10 minutes to complete
- **Lifecycle Protection**: Account cannot be accidentally deleted (prevent_destroy = true)
- **Bootstrap Role**: Automatically created for cross-account access
- **Cost**: Free to create accounts, only pay for resources used
- **Email Uniqueness**: The email address must be unique across all AWS accounts globally

## Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `account_name` | Name for the new AWS account | `"MyProject"` |
| `account_email` | Email address (must be unique) | `"myproject@company.com"` |

### Optional Variables

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `parent_ou_id` | ID of the parent OU | `null` | `"ou-xxxxxxxxx-xxxxxxxxx"` |
| `iam_user_access_to_billing` | Allow IAM users to access billing | `"DENY"` | `"ALLOW"` or `"DENY"` |
| `tags` | Tags to apply to the account | `{}` | `{"Environment": "prod"}` |

### Variable Validation

The module includes comprehensive validation:

- **Account Name**: 1-50 characters
- **Email**: Valid email format
- **OU ID**: Valid AWS OU ID format or null
- **Billing Access**: Must be "ALLOW" or "DENY"

## Outputs

| Output | Description |
|--------|-------------|
| `account_id` | The ID of the newly created AWS account |
| `account_arn` | The ARN of the newly created AWS account |
| `account_name` | The name of the newly created AWS account |
| `account_email` | The email address of the newly created AWS account |
| `account_status` | The status of the newly created AWS account |
| `account_joined_method` | How the account was joined to the organization |
| `account_joined_timestamp` | When the account was joined |
| `bootstrap_role_arn` | ARN of the bootstrap role for cross-account access |

## Security Features

### Lifecycle Protection
```hcl
lifecycle {
  prevent_destroy = true
}
```
The account cannot be accidentally deleted through Terraform.

### Bootstrap Role
The `OrganizationAccountAccessRole` is automatically created by AWS Organizations and provides:
- Full access to the member account
- Trust policy allowing management account to assume the role
- Standard AWS Organizations security model

## Usage Examples

### Basic Account Creation
```bash
# Minimal configuration
export TF_VAR_account_name="MyProject"
export TF_VAR_account_email="myproject@company.com"
terraform apply
```

### Account with Custom OU
```bash
# Place account in specific OU
export TF_VAR_account_name="MyProject"
export TF_VAR_account_email="myproject@company.com"
export TF_VAR_parent_ou_id="ou-xxxxxxxxx-xxxxxxxxx"
terraform apply
```

### Account with Custom Tags
```bash
# Add custom tags
export TF_VAR_account_name="MyProject"
export TF_VAR_account_email="myproject@company.com"
export TF_VAR_tags='{"Environment": "production", "Owner": "my-team"}'
terraform apply
```

## Integration with Other Modules

### With Users Module
```bash
# Get account ID for users module
ACCOUNT_ID=$(terraform output -raw account_id)

# Use in users module
cd ../users
terraform apply -var="member_account_id=$ACCOUNT_ID"
```

### With Networking Module
```bash
# Get account ID for networking module
ACCOUNT_ID=$(terraform output -raw account_id)

# Use in networking module
cd ../networking
terraform apply -var="account_id=$ACCOUNT_ID"
```

## Troubleshooting

### Common Issues

#### 1. Email Already Exists
```
Error: email already exists
```
**Solution**: Use a unique email address that hasn't been used for any AWS account.

#### 2. Invalid OU ID
```
Error: Invalid OU ID format
```
**Solution**: Ensure the OU ID follows the format `ou-xxxxxxxxx-xxxxxxxxx` or set to `null`.

#### 3. Insufficient Permissions
```
Error: Access denied
```
**Solution**: Ensure your AWS credentials have Organizations management permissions.

#### 4. Account Creation Timeout
```
Error: Account creation taking longer than expected
```
**Solution**: Account creation can take 5-10 minutes. Wait and check the AWS Organizations console.

### Verification Steps

#### 1. Check Account Status
```bash
# Check account status
terraform output account_status

# Should show "ACTIVE" when ready
```

#### 2. Verify Bootstrap Role
```bash
# Test bootstrap role assumption
aws sts assume-role \
  --role-arn "$(terraform output -raw bootstrap_role_arn)" \
  --role-session-name "test" \
  --profile your-aws-profile
```

#### 3. Check AWS Organizations Console
- Navigate to AWS Organizations console
- Verify the account appears in the correct OU
- Check account status is "Active"

## Best Practices

### 1. Naming Conventions
- Use descriptive account names
- Include environment or project identifiers
- Keep names under 50 characters

### 2. Email Management
- Use dedicated email addresses for accounts
- Consider using email aliases for easy management
- Document email ownership

### 3. OU Structure
- Plan your OU hierarchy before creating accounts
- Use OUs for billing, security, and access control
- Document OU purposes and policies

### 4. Tagging Strategy
- Apply consistent tags across all accounts
- Include Environment, Owner, Project tags
- Use tags for cost allocation and governance

### 5. Security
- Always use `prevent_destroy = true` for production accounts
- Regularly audit account access and permissions
- Monitor account activity and costs

## Cost Considerations

### Account Creation
- **Cost**: Free to create accounts
- **Billing**: Each account has separate billing
- **Monitoring**: Set up billing alerts for new accounts

### Ongoing Costs
- **AWS Services**: Only pay for resources used in the account
- **Organizations**: No additional cost for organization membership
- **Cross-Account**: No cost for cross-account role assumption

## Next Steps

After creating the account:

1. **Set up IAM Users**: Use the [Users Module](../users/) to create IAM users
2. **Configure Networking**: Use the [Networking Module](../networking/) to set up VPC infrastructure
3. **Set up Monitoring**: Configure CloudWatch and billing alerts
4. **Security Hardening**: Implement security best practices
5. **Documentation**: Document account purpose and access procedures

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review AWS Organizations documentation
3. Check Terraform AWS provider documentation
4. Verify your AWS permissions and configuration
