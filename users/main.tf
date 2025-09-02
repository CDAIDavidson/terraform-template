# Stage 2: Create IAM users in the member account
# This stage assumes the account has been created in Stage 1

# Provider for the management account (for any cross-account operations)
provider "aws" {
  region = var.management_region
}

# Provider for the new member account (assumes the bootstrap role)
provider "aws" {
  alias  = "new"
  region = var.new_account_region
  assume_role {
    role_arn     = "arn:aws:iam::${var.member_account_id}:role/${var.bootstrap_role_name}"
    session_name = "tf-member"
  }
}

# Safety check: Verify we're in the correct member account
data "aws_caller_identity" "member" {
  provider = aws.new
}

# Create developer user in the new account
resource "aws_iam_user" "developer" {
  count    = var.enable_developer_user ? 1 : 0
  provider = aws.new
  name     = var.developer_user_name
  path     = "/users/"
  
  tags = merge(var.tags, {
    Environment = "development"
    Name        = "Developer User"
    Purpose     = "application-development"
  })
}

# Create access keys for the developer
resource "aws_iam_access_key" "developer" {
  count    = var.enable_developer_user ? 1 : 0
  provider = aws.new
  user     = aws_iam_user.developer[0].name
}

# Attach AdministratorAccess policy for full admin rights
resource "aws_iam_user_policy_attachment" "developer_admin" {
  count      = var.enable_developer_user ? 1 : 0
  provider   = aws.new
  user       = aws_iam_user.developer[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create login profile for console access
resource "aws_iam_user_login_profile" "developer" {
  count                   = var.enable_developer_user ? 1 : 0
  provider                = aws.new
  user                    = aws_iam_user.developer[0].name
  password_reset_required = true
  password_length         = 20
}

# Create admin user in the new account
resource "aws_iam_user" "admin" {
  count    = var.enable_admin_user ? 1 : 0
  provider = aws.new
  name     = var.admin_user_name
  path     = "/users/"
  
  tags = merge(var.tags, {
    Environment = "production"
    Name        = "Admin User"
    Purpose     = "account-administration"
  })
}

# Create access keys for the admin
resource "aws_iam_access_key" "admin" {
  count    = var.enable_admin_user ? 1 : 0
  provider = aws.new
  user     = aws_iam_user.admin[0].name
}

# Attach AdministratorAccess policy for full admin rights
resource "aws_iam_user_policy_attachment" "admin_admin" {
  count      = var.enable_admin_user ? 1 : 0
  provider   = aws.new
  user       = aws_iam_user.admin[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create login profile for console access
resource "aws_iam_user_login_profile" "admin" {
  count                   = var.enable_admin_user ? 1 : 0
  provider                = aws.new
  user                    = aws_iam_user.admin[0].name
  password_reset_required = true
  password_length         = 20
}

# Create monitor user in the new account
resource "aws_iam_user" "monitor" {
  count    = var.enable_monitor_user ? 1 : 0
  provider = aws.new
  name     = var.monitor_user_name
  path     = "/users/"
  
  tags = merge(var.tags, {
    Environment = "monitoring"
    Name        = "Monitor User"
    Purpose     = "monitoring-compliance"
  })
}

# Create access keys for the monitor
resource "aws_iam_access_key" "monitor" {
  count    = var.enable_monitor_user ? 1 : 0
  provider = aws.new
  user     = aws_iam_user.monitor[0].name
}

# Attach ReadOnlyAccess policy for read-only access
resource "aws_iam_user_policy_attachment" "monitor_readonly" {
  count      = var.enable_monitor_user ? 1 : 0
  provider   = aws.new
  user       = aws_iam_user.monitor[0].name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Create login profile for console access
resource "aws_iam_user_login_profile" "monitor" {
  count                   = var.enable_monitor_user ? 1 : 0
  provider                = aws.new
  user                    = aws_iam_user.monitor[0].name
  password_reset_required = true
  password_length         = 20
}