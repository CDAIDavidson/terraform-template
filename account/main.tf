# Account Creation Module
# This module creates a new AWS account in the Organization

# Local values for computed resources
locals {
  # Common tags applied to all resources
  common_tags = merge(var.tags, {
    Module    = "account"
    ManagedBy = "terraform"
  })
}

# Create a new AWS account in the Organization
resource "aws_organizations_account" "new_account" {
  name                       = var.account_name
  email                      = var.account_email
  iam_user_access_to_billing = var.iam_user_access_to_billing
  parent_id                  = var.parent_ou_id
  tags                       = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}
