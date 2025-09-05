# Assure360 CI/CD Pipeline with GitHub Actions

This document explains how the CI/CD pipeline works and how to add new repositories to the automated deployment system.

## 🏗️ **Pipeline Overview**

The CI/CD pipeline uses **GitHub Actions** with **AWS OIDC (OpenID Connect)** for secure, keyless authentication. No Personal Access Tokens (PATs) or long-lived credentials are required.

### **Key Features**
- ✅ **Zero Secrets**: Uses OIDC authentication (no PATs/keys)
- ✅ **MFA Compatible**: Works with existing MFA-only setup
- ✅ **Branch-based Deployment**: Different environments for different branches
- ✅ **Manual Approval**: Production deployments require approval
- ✅ **Security Scanning**: Automated security checks on every PR
- ✅ **Audit Trail**: Complete logging and session tagging

## 🔄 **Pipeline Flow**

### **Development Flow**
```
Feature Branch → Pull Request → Security Scan → Plan Review → Merge to develop → Auto Deploy to Dev
```

### **Production Flow**
```
develop → Merge to main → Auto Deploy to Production
```

## 🌍 **Environments**

| Branch | Environment | Auto Deploy | Approval Required |
|--------|-------------|-------------|-------------------|
| `feature/*` | None | ❌ | N/A |
| `develop` | Development | ✅ | ❌ |
| `main` | Production | ✅ | ❌ |

## 📋 **Workflows**

### **1. Terraform Plan** (`.github/workflows/terraform-plan.yml`)
- **Triggers**: Pull requests to `main` or `develop`
- **Actions**:
  - Runs `terraform plan` for all modules
  - Uploads plan artifacts
  - Comments on PR with plan details
  - Security scanning (Checkov, Trivy, TFSec)

### **2. Development Deploy** (`.github/workflows/terraform-apply-dev.yml`)
- **Triggers**: Push to `develop` branch
- **Actions**:
  - Automatically deploys to development environment
  - Uploads deployment outputs
  - No approval required

### **3. Production Deploy** (`.github/workflows/terraform-apply-prod.yml`)
- **Triggers**: Push to `main` branch
- **Actions**:
  - Automatically deploys to production environment
  - Uploads deployment outputs
  - No approval required

### **4. Security Scan** (`.github/workflows/security-scan.yml`)
- **Triggers**: Pull requests and pushes
- **Actions**:
  - Runs Checkov (Terraform security)
  - Runs Trivy (vulnerability scanning)
  - Runs TFSec (Terraform security)
  - Uploads results to GitHub Security tab

### **5. Destroy Resources** (`.github/workflows/terraform-destroy.yml`)
- **Triggers**: Manual workflow dispatch
- **Actions**:
  - Destroys specified modules/environments
  - Requires confirmation ("DESTROY")
  - Creates cleanup issues for manual verification

## 🔐 **Authentication & Security**

### **AWS OIDC Provider**
- **URL**: `https://token.actions.githubusercontent.com`
- **Client ID**: `sts.amazonaws.com`
- **Trust Policy**: Repository and branch-specific

### **IAM Roles**
- **Development Role**: `github-actions-dev-role`
  - Access: Any branch from specified repositories
  - Permissions: Full Terraform deployment rights
- **Production Role**: `github-actions-prod-role`
  - Access: Only `main` branch from specified repositories
  - Permissions: Full Terraform deployment rights

### **Security Features**
- **Branch Restrictions**: Prod role only works on main branch
- **Repository Restrictions**: Only specified repos can assume roles
- **Session Tagging**: All actions are tagged for audit
- **MFA Compatible**: Works with existing MFA-only setup

## 🚀 **Adding a New Repository**

### **Step 1: Update Terraform Configuration**

Edit `assure360/iam-foundation/terraform.tfvars`:

```hcl
github_repositories = [
  "terraform-templates",
  "assure360-app",
  "your-new-repo"  # Add your repository here
]
```

### **Step 2: Apply Terraform Changes**

```bash
cd assure360/iam-foundation
terraform plan
terraform apply
```

### **Step 3: Set Up GitHub Repository Secrets**

In your new repository, go to **Settings → Secrets and variables → Actions** and add:

| Secret Name | Value | How to Get |
|-------------|-------|------------|
| `AWS_ROLE_ARN_DEV` | `arn:aws:iam::ACCOUNT:role/github-actions-dev-role` | `terraform output github_actions_dev_role_arn` |
| `AWS_ROLE_ARN_PROD` | `arn:aws:iam::ACCOUNT:role/github-actions-prod-role` | `terraform output github_actions_prod_role_arn` |
| `APPROVERS` | `username1,username2` | Comma-separated GitHub usernames |

### **Step 4: Copy Workflow Files**

Copy the workflow files from this repository to your new repository:

```bash
# Copy all workflow files
cp -r .github/workflows/ /path/to/your/new/repo/.github/
```

### **Step 5: Test the Pipeline**

1. **Create a feature branch** with some changes
2. **Open a pull request** to `develop`
3. **Verify the plan workflow runs** and shows the Terraform plan
4. **Merge to develop** to test auto-deployment
5. **Merge to main** to test production deployment (with approval)

## 📁 **Repository Structure**

Your repository should have this structure for the pipeline to work:

```
your-repo/
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml
│       ├── terraform-apply-dev.yml
│       ├── terraform-apply-prod.yml
│       ├── security-scan.yml
│       └── terraform-destroy.yml
├── assure360/
│   ├── iam-foundation/
│   ├── iam-users/
│   └── networking/
└── README.md
```

## 🔧 **Configuration Options**

### **Environment Variables**

The workflows use these environment variables (set in each workflow file):

```yaml
env:
  TF_VERSION: '1.6.0'
  AWS_REGION: 'ap-southeast-2'
  ENVIRONMENT: 'dev'  # or 'prod'
```

### **Matrix Strategy**

The workflows run in parallel for each Terraform module:

```yaml
strategy:
  matrix:
    module: [iam-foundation, iam-users, networking]
```

## 🚨 **Troubleshooting**

### **Common Issues**

#### **1. Authentication Failed**
```
Error: No valid credential sources found
```
**Solution**: Check that the repository secrets are set correctly and the OIDC provider is configured.

#### **2. Permission Denied**
```
Error: User is not authorized to perform: sts:AssumeRoleWithWebIdentity
```
**Solution**: Verify the repository is in the `github_repositories` list in Terraform.

#### **3. Branch Not Allowed**
```
Error: Access denied for branch 'feature/xyz'
```
**Solution**: Production role only allows `main` branch. Use development role for other branches.

### **Debugging Steps**

1. **Check GitHub Actions logs** for detailed error messages
2. **Verify repository secrets** are set correctly
3. **Confirm Terraform configuration** includes your repository
4. **Check AWS CloudTrail** for authentication attempts

## 📊 **Monitoring & Alerts**

### **GitHub Actions**
- **Status**: Check the Actions tab in your repository
- **Logs**: Detailed logs for each workflow run
- **Artifacts**: Plan files and outputs are stored as artifacts

### **AWS CloudTrail**
- **Authentication**: All OIDC authentication attempts are logged
- **API Calls**: All AWS API calls are tracked
- **Session Tags**: Actions are tagged with repository and branch info

## 🔄 **Maintenance**

### **Regular Tasks**
- **Review security scan results** in GitHub Security tab
- **Update Terraform version** in workflow files as needed
- **Rotate approvers** list for production deployments
- **Monitor CloudTrail logs** for any unauthorized access

### **Updates**
- **Workflow updates**: Copy updated workflow files to all repositories
- **Terraform updates**: Update the IAM foundation module and apply changes
- **Security updates**: Keep security scanning tools updated

## 📞 **Support**

For issues with the CI/CD pipeline:

1. **Check this documentation** first
2. **Review GitHub Actions logs** for error details
3. **Check AWS CloudTrail** for authentication issues
4. **Contact the Platform Team** for Terraform configuration issues

---

## 🎯 **Quick Reference**

### **Adding a Repository**
1. Add repo to `terraform.tfvars`
2. Run `terraform apply`
3. Set GitHub secrets
4. Copy workflow files
5. Test with a PR

### **Deployment Flow**
- **Feature → PR → Plan → Review → Merge to develop → Auto Deploy**
- **develop → Merge to main → Auto Deploy to Production**

### **Key Commands**
```bash
# Get role ARNs for GitHub secrets
terraform output github_actions_dev_role_arn
terraform output github_actions_prod_role_arn

# Plan changes
terraform plan

# Apply changes
terraform apply
```
