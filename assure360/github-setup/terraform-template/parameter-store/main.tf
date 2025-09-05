# Stage 3: Create Parameter Store items in the member account
# This stage creates secure parameters for storing client and secret keys
# Assumes the account and users have been created in previous stages

# Provider for the management account (for any cross-account operations)
provider "aws" {
  region = var.management_region
}

# Provider for the member account (assumes the bootstrap role)
provider "aws" {
  alias  = "member"
  region = var.member_account_region
  assume_role {
    role_arn     = "arn:aws:iam::${var.member_account_id}:role/${var.bootstrap_role_name}"
    session_name = "tf-parameter-store"
  }
}

# Safety check: Verify we're in the correct member account
data "aws_caller_identity" "member" {
  provider = aws.member
}

# Locals for secrets processing
locals {
  secrets_input = var.secrets
}

# Create KMS key for Parameter Store encryption
resource "aws_kms_key" "parameter_store" {
  provider = aws.member
  description             = "KMS key for Parameter Store encryption"
  deletion_window_in_days = 7
  
  tags = {
    Name        = "parameter-store-key"
    Environment = var.environment
    Purpose     = "parameter-store-encryption"
  }
}

# Create KMS key alias
resource "aws_kms_alias" "parameter_store" {
  provider      = aws.member
  name          = "alias/parameter-store-key"
  target_key_id = aws_kms_key.parameter_store.key_id
}

# Create IAM policy for Parameter Store access
resource "aws_iam_policy" "parameter_store_access" {
  provider = aws.member
  name     = "ParameterStoreAccess"
  path     = "/"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:DescribeParameters"
        ]
        Resource = [
          "arn:aws:ssm:${var.member_account_region}:${var.member_account_id}:parameter/${var.parameter_prefix}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          aws_kms_key.parameter_store.arn
        ]
      }
    ]
  })
  
  tags = {
    Name        = "ParameterStoreAccess"
    Environment = var.environment
    Purpose     = "parameter-store-permissions"
  }
}

# Attach Parameter Store policy to the developer user
resource "aws_iam_user_policy_attachment" "developer_parameter_store" {
  provider   = aws.member
  user       = var.developer_username
  policy_arn = aws_iam_policy.parameter_store_access.arn
}

# Service credentials - create one parameter per service
resource "aws_ssm_parameter" "secrets" {
  for_each  = local.secrets_input
  provider  = aws.member
  name      = "/${trim(var.parameter_prefix, "/")}/${each.key}"
  type      = "SecureString"
  value     = jsonencode(each.value)
  key_id    = aws_kms_key.parameter_store.key_id
  overwrite = true
  tier      = length(jsonencode(each.value)) > 4096 ? "Advanced" : "Standard"
  
  tags = {
    Name        = title(replace(each.key, "_", " "))
    Environment = var.environment
    Purpose     = "service-credentials"
    Service     = each.key
    Sensitive   = "true"
  }

  lifecycle {
    precondition {
      condition     = length(local.secrets_input) > 0
      error_message = "At least one service credential must be provided in TF_VAR_secrets."
    }
    
    precondition {
      condition     = can(jsonencode(each.value))
      error_message = "Service credential '${each.key}' must be valid JSON."
    }
  }
}




