# IAM Foundation

This Terraform root creates a clean IAM foundation for a single account using the small-team baseline approach.

## Groups

- **davidson-admins** → AdministratorAccess
- **davidson-developers** → DavidsonDevMinimal + DavidsonRequireMFA, can assume `davidson-dev-elevated-role` (PowerUser with MFA)
- **davidson-support** → ReadOnlyAccess + DavidsonRequireMFA

## Policies

- **DavidsonDevMinimal** → curated day-to-day developer rights
- **DavidsonRequireMFA** → deny if MFA not present
- **DavidsonAssumeDevElevated** → allows assuming the elevated role

## Role

- **davidson-dev-elevated-role** → PowerUserAccess, requires MFA to assume, 1h session

## Notes

- All IAM usernames must be prefixed with `davidson-`.
- Keep `davidson-admins` group membership very small.
- Developers use their minimal rights by default, and only assume the elevated role when needed.

## What This Does

Creates the foundational IAM infrastructure:
- **IAM Groups**: Three groups with appropriate access levels
- **IAM Policies**: Custom Davidson policies for developers and MFA enforcement
- **IAM Role**: Elevated role for developers requiring MFA
- **Policy Attachments**: Links policies to the appropriate groups

## Prereqs

- Your local AWS credentials target the target account (e.g., `AWS_PROFILE=<profile>`)
- Appropriate permissions to create IAM groups, policies, and roles

## target the target account 
```bash
export AWS_PROFILE=<>
```

### Initialize First (Required)
```bash
cd assure360/iam-foundation
terraform init
```

### Plan Script
```bash
cd assure360/iam-foundation
chmod +x plan.sh
./plan.sh
```

### Apply Script
```bash
cd assure360/iam-foundation
chmod +x apply.sh
./apply.sh
```

## Step-by-Step Instructions

### Step 1: Navigate to Directory
```bash
cd assure360/iam-foundation
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
# IMPORTANT: Run this first before planning or applying
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

### IAM Groups

#### davidson-admins
- **Purpose**: Administrative access
- **Policies**: AWS managed AdministratorAccess
- **Usage**: Keep membership very small, only for critical administrative tasks

#### davidson-developers
- **Purpose**: Developer access with minimal permissions
- **Policies**: 
  - DavidsonDevMinimal (curated developer rights)
  - DavidsonRequireMFA (MFA enforcement)
  - DavidsonAssumeDevElevated (can assume elevated role)
- **Usage**: Day-to-day development work with ability to elevate when needed

#### davidson-support
- **Purpose**: Support and troubleshooting access
- **Policies**: 
  - AWS managed ReadOnlyAccess
  - DavidsonRequireMFA (MFA enforcement)
- **Usage**: Read-only access for support tasks

### IAM Policies

#### DavidsonDevMinimal
- **Purpose**: Curated day-to-day developer rights
- **Permissions**:
  - CloudWatch, CloudTrail, X-Ray monitoring
  - EC2, RDS, ECR, Lambda describe/list operations
  - SSM parameter store access
  - S3 bucket listing and location
  - Lambda function updates and invocations
  - ECR image push/pull operations
  - Project-specific S3 buckets (assure360-*)

#### DavidsonRequireMFA
- **Purpose**: Enforce MFA for all actions
- **Effect**: Denies all actions if MFA is not present
- **Applied to**: developers and support groups

#### DavidsonAssumeDevElevated
- **Purpose**: Allow assuming the elevated role
- **Permissions**: sts:AssumeRole on davidson-dev-elevated-role
- **Applied to**: developers group only

### IAM Role

#### davidson-dev-elevated-role
- **Purpose**: Elevated permissions for developers when needed
- **Policies**: AWS managed PowerUserAccess
- **Session Duration**: 1 hour maximum
- **MFA Required**: Yes, must have MFA to assume
- **Assumption**: Only by users in davidson-developers group

## Verify Deployment

### Check Groups
```bash
aws iam list-groups --query 'Groups[?contains(GroupName, `davidson-`)]'
```

### Check Policies
```bash
aws iam list-policies --query 'Policies[?contains(PolicyName, `Davidson`)]'
```

### Check Role
```bash
aws iam get-role --role-name davidson-dev-elevated-role
```

### Check Group Policy Attachments
```bash
# Check developers group
aws iam list-attached-group-policies --group-name davidson-developers

# Check support group
aws iam list-attached-group-policies --group-name davidson-support

# Check admins group
aws iam list-attached-group-policies --group-name davidson-admins
```

## Usage Examples

### Assuming the Elevated Role
```bash
# Developers can assume the elevated role (requires MFA)
aws sts assume-role \
  --role-arn arn:aws:iam::ACCOUNT:role/davidson-dev-elevated-role \
  --role-session-name dev-session
```

### Creating Users
When creating IAM users, ensure they follow the naming convention:
- Username must be prefixed with `davidson-`
- Example: `davidson-alice.smith`, `davidson-bob.jones`

## Security Features

### MFA Enforcement
- All actions by developers and support users require MFA
- Elevated role assumption requires MFA
- Policies automatically deny access without MFA

### Principle of Least Privilege
- Developers get minimal permissions by default
- Elevated access is temporary and requires explicit assumption
- Support users have read-only access only

### Naming Convention
- All usernames must be prefixed with `davidson-`
- All groups, policies, and roles follow consistent naming
- Easy to identify and manage Davidson-related resources

## Configuration Files

- **`main.tf`**: Core Terraform configuration for IAM groups, policies, and roles
- **`variables.tf`**: Variable definitions including user prefix
- **`outputs.tf`**: Outputs for group, policy, and role information
- **`versions.tf`**: Terraform and provider version constraints
- **`env.example`**: Environment variable template (copy to `.env` to customize)
- **`plan.sh`**: Shell script for running `terraform plan`
- **`apply.sh`**: Shell script for running `terraform apply`

## Troubleshooting

### Group Already Exists
If any of the groups already exist, the Terraform apply will fail. Either:
1. Import the existing group: `terraform import aws_iam_group.admins davidson-admins`
2. Or modify the group name in the configuration

### Permission Denied
Ensure your AWS credentials have the following permissions:
- `iam:CreateGroup`
- `iam:CreatePolicy`
- `iam:CreateRole`
- `iam:AttachGroupPolicy`
- `iam:AttachRolePolicy`

### Policy Conflicts
If policies with the same names already exist, either:
1. Import them: `terraform import aws_iam_policy.dev_minimal arn:aws:iam::ACCOUNT:policy/DavidsonDevMinimal`
2. Or modify the policy names in the configuration

### MFA Issues
- Ensure MFA is enabled for users before they try to use the policies
- The DavidsonRequireMFA policy will deny all actions if MFA is not present
- Users must have MFA enabled to assume the elevated role

## Next Steps

After successful deployment:

1. **Create IAM users** with the `davidson-` prefix
2. **Add users to appropriate groups** based on their role
3. **Enable MFA** for all users
4. **Test access** to ensure policies work as expected
5. **Document user onboarding process** for your team

## Cost Considerations

- IAM groups, policies, and roles are free
- No additional costs for this foundation
- Consider implementing cost monitoring for elevated role usage