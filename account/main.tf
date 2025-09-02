# Stage 1: Create a new AWS account in the Organization
# This is the simple, clean version that just creates the account

resource "aws_organizations_account" "new_account" {
  name                       = var.account_name
  email                      = var.account_email
  iam_user_access_to_billing = var.iam_user_access_to_billing
  parent_id                  = var.parent_ou_id
  tags                       = var.tags
}
