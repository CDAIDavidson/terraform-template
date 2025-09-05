# GitHub Secrets Setup for CI/CD

This document outlines the required GitHub repository secrets for the CI/CD pipeline.

## Required Secrets

### AWS Role ARNs
- `AWS_ROLE_ARN_DEV`: ARN of the GitHub Actions development role
- `AWS_ROLE_ARN_PROD`: ARN of the GitHub Actions production role

### Optional Secrets
- `APPROVERS`: Comma-separated list of GitHub usernames who can approve production deployments

## How to Get the Role ARNs

After applying the Terraform configuration with GitHub OIDC enabled, you can get the role ARNs from the Terraform outputs:

```bash
# Apply the IAM foundation with GitHub OIDC enabled
cd assure360/iam-foundation
terraform apply

# Get the role ARNs
terraform output github_actions_dev_role_arn
terraform output github_actions_prod_role_arn
```

## Setting Up Secrets in GitHub

1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret with the corresponding value

## Example Values

```
AWS_ROLE_ARN_DEV: arn:aws:iam::192933325286:role/github-actions-dev-role
AWS_ROLE_ARN_PROD: arn:aws:iam::192933325286:role/github-actions-prod-role
APPROVERS: username1,username2,username3
```

## Verification

After setting up the secrets, you can verify the setup by:

1. Creating a pull request with changes to the `assure360/` directory
2. The Terraform Plan workflow should run automatically
3. Check the Actions tab to see the workflow execution

## Security Notes

- The development role allows access from any branch
- The production role only allows access from the `main` branch
- All workflows use OIDC authentication (no long-lived credentials)
- Production deployments require manual approval
