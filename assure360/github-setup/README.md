# GitHub Repository Secrets Setup

This folder contains scripts to automatically set up GitHub repository secrets for the CI/CD pipeline.

## 📋 **What This Does**

- Sets up GitHub repository secrets for both repositories
- Configures AWS role ARNs for GitHub Actions OIDC authentication
- Automates the CI/CD pipeline setup process

## 🚀 **Quick Start (Simplest Way)**

### **Prerequisites**

1. **GitHub CLI installed**:
   ```bash
   # Windows
   winget install GitHub.cli
   
   # macOS
   brew install gh
   
   # Linux
   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages/ github-cli main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
   sudo apt update
   sudo apt install gh
   ```

2. **Authenticated with GitHub**:
   ```bash
   gh auth login
   ```

3. **Terraform applied** (to get the role ARNs):
   ```bash
   cd ../iam-foundation
   terraform apply
   ```

### **One-Command Setup (Secrets Only)**

```bash
# Navigate to the github-setup directory
cd assure360/github-setup

# Copy environment template and update with your values
cp env.example .env
# Edit .env with your actual role ARNs

# Run the secrets setup
./setup-secrets-only.sh
```

**That's it!** The script will:
- ✅ Set up GitHub repository secrets from .env file
- ✅ Verify secrets are set correctly
- ✅ No cloning or file copying

### **Complete Setup (Secrets + Workflows)**

If you also want to copy workflow files to repositories:

```bash
# Run the complete setup
./setup-cicd.sh
```

This will:
- ✅ Set up GitHub repository secrets
- ✅ Copy workflow files to repositories
- ✅ Commit and push changes
- ✅ Verify everything is working

## 🔧 **Advanced Setup (If You Need More Control)**

If you need to run specific steps separately, you can modify the `setup-cicd.sh` script or create custom scripts based on the functions within it.

## 🔧 **Manual Setup**

If you prefer to set up secrets manually:

### **1. Get Role ARNs**
```bash
cd ../iam-foundation
terraform output github_actions_dev_role_arn
terraform output github_actions_prod_role_arn
```

### **2. Set Secrets for Each Repository**

#### **terraform-template:**
```bash
gh secret set AWS_ROLE_ARN_DEV --repo CDAIDavidson/terraform-template --body "YOUR_DEV_ROLE_ARN"
gh secret set AWS_ROLE_ARN_PROD --repo CDAIDavidson/terraform-template --body "YOUR_PROD_ROLE_ARN"
```

#### **scaffold_aws_bda_doc_parser:**
```bash
gh secret set AWS_ROLE_ARN_DEV --repo CDAIDavidson/scaffold_aws_bda_doc_parser --body "YOUR_DEV_ROLE_ARN"
gh secret set AWS_ROLE_ARN_PROD --repo CDAIDavidson/scaffold_aws_bda_doc_parser --body "YOUR_PROD_ROLE_ARN"
```

## 📁 **Environment Configuration**

### **Environment Variables**

The scripts use the following environment variables (set in `.env` file):

| Variable | Description | Example |
|----------|-------------|---------|
| `AWS_ROLE_ARN_DEV` | Development role ARN | `arn:aws:iam::123456789012:role/github-actions-dev-role` |
| `AWS_ROLE_ARN_PROD` | Production role ARN | `arn:aws:iam::123456789012:role/github-actions-prod-role` |
| `GITHUB_ORG` | GitHub organization | `CDAIDavidson` |
| `GITHUB_REPOS` | Comma-separated repositories | `CDAIDavidson/terraform-template,CDAIDavidson/scaffold_aws_bda_doc_parser` |
| `GITHUB_PROFILE` | GitHub CLI profile (for multiple accounts) | `your-username` |
| `COMMIT_MESSAGE` | Custom commit message | `Add CI/CD workflows` |
| `BRANCH_NAME` | Target branch for workflows | `main` |

### **Getting Role ARNs**

```bash
# From Terraform outputs
cd ../iam-foundation
terraform output github_actions_dev_role_arn
terraform output github_actions_prod_role_arn

# Or from the .env file after running terraform
grep AWS_ROLE_ARN .env
```

### **Managing Multiple GitHub Profiles**

If you have multiple GitHub accounts, you can specify which one to use:

#### **Option 1: Set in .env file**
```bash
# Add to your .env file
GITHUB_PROFILE="your-username"
```

#### **Option 2: Set before running script**
```bash
# Navigate to the github-setup directory
cd assure360/github-setup

# Set profile for current session
export GITHUB_PROFILE="your-username"

# Run script
./setup-cicd.sh
```

#### **Option 3: Use GitHub CLI commands**
```bash
# Navigate to the github-setup directory
cd assure360/github-setup

# List all authenticated accounts
gh auth status

# Switch to specific account
gh auth switch --user your-username

# Run script
./setup-cicd.sh
```

#### **Check Current Profile**
```bash
# See which account is currently active
gh api user --jq .login
```

## 📁 **Repository Structure**

```
assure360/
├── iam-foundation/          # IAM and OIDC setup
├── networking/              # Network infrastructure
├── github-setup/            # This folder
│   ├── README.md           # This file
│   ├── setup-cicd.sh       # Complete CI/CD setup script
│   └── env.example         # Configuration template
└── ...
```

## 🔍 **Verification**

After running the setup, verify everything is configured:

### **Check Secrets**
```bash
# Navigate to the github-setup directory
cd assure360/github-setup

# List secrets for terraform-template
gh secret list --repo CDAIDavidson/terraform-template

# List secrets for scaffold_aws_bda_doc_parser
gh secret list --repo CDAIDavidson/scaffold_aws_bda_doc_parser
```

### **Check Workflows**
```bash
# Navigate to the github-setup directory
cd assure360/github-setup

# List workflows for terraform-template
gh workflow list --repo CDAIDavidson/terraform-template

# List workflows for scaffold_aws_bda_doc_parser
gh workflow list --repo CDAIDavidson/scaffold_aws_bda_doc_parser
```

## 🧪 **Testing the Pipeline**

### **1. Create a Test PR**
```bash
# Navigate to the github-setup directory
cd assure360/github-setup

# Create a test branch
git checkout -b test-cicd-setup

# Make a small change
echo "# Test CI/CD" >> README.md

# Commit and push
git add README.md
git commit -m "Test CI/CD pipeline"
git push origin test-cicd-setup

# Create a pull request
gh pr create --title "Test CI/CD Pipeline" --body "Testing the new CI/CD setup"
```

### **2. Monitor the Workflow**
```bash
# Navigate to the github-setup directory
cd assure360/github-setup

# Watch the workflow run
gh run watch --repo CDAIDavidson/terraform-template

# List recent workflow runs
gh run list --repo CDAIDavidson/terraform-template
```

## 🚨 **Troubleshooting**

### **Common Issues**

#### **1. GitHub CLI Not Authenticated**
```bash
# Navigate to the github-setup directory
cd assure360/github-setup

gh auth status
# If not authenticated, run:
gh auth login
```

#### **2. Repository Not Found**
```bash
# Navigate to the github-setup directory
cd assure360/github-setup

# Check if you have access to the repository
gh repo view CDAIDavidson/terraform-template
```

#### **3. Secrets Not Set**
```bash
# Navigate to the github-setup directory
cd assure360/github-setup

# Verify secrets were set correctly
gh secret list --repo CDAIDavidson/terraform-template
```

#### **4. Workflow Not Running**
- Check that the workflow files are in `.github/workflows/`
- Verify the repository has the correct branch protection rules
- Check the workflow syntax in GitHub Actions tab

### **Debug Commands**

```bash
# Navigate to the github-setup directory
cd assure360/github-setup

# Check GitHub CLI version
gh --version

# Check authentication status
gh auth status

# List all repositories you have access to
gh repo list CDAIDavidson

# Check specific repository details
gh repo view CDAIDavidson/terraform-template
```

## 📚 **Additional Resources**

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [GitHub Actions OIDC Documentation](https://docs.github.com/en/actions/deployment/security/hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS IAM OIDC Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)

## 🎯 **Next Steps**

After setting up the secrets:

1. **Copy workflow files** to both repositories
2. **Test the pipeline** with a sample PR
3. **Monitor deployments** in GitHub Actions
4. **Set up branch protection rules** for production safety

---

**Need help?** Check the troubleshooting section above or review the main CI/CD documentation.
