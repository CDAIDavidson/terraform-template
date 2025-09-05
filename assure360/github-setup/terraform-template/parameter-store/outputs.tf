# Stage 3 Outputs - Parameter Store Information

# Member account information
output "member_account_id" {
  description = "The ID of the member account"
  value       = data.aws_caller_identity.member.account_id
}

output "member_caller_identity" {
  description = "The caller identity in the member account"
  value       = data.aws_caller_identity.member
}

# KMS Key information
output "kms_key_id" {
  description = "The ID of the KMS key used for Parameter Store encryption"
  value       = aws_kms_key.parameter_store.key_id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for Parameter Store encryption"
  value       = aws_kms_key.parameter_store.arn
}

output "kms_key_alias" {
  description = "The alias of the KMS key"
  value       = aws_kms_alias.parameter_store.name
}

# Parameter Store information
output "parameter_prefix" {
  description = "The prefix used for all Parameter Store parameters"
  value       = var.parameter_prefix
}

output "parameter_names" {
  description = "The names of all created Parameter Store parameters"
  sensitive   = true
  value = {
    secrets = aws_ssm_parameter.secrets
  }
}

output "parameter_arns" {
  description = "The ARNs of all created Parameter Store parameters"
  value = {
    secrets = { for k, v in aws_ssm_parameter.secrets : k => v.arn }
  }
}

# IAM Policy information
output "parameter_store_policy_arn" {
  description = "The ARN of the IAM policy for Parameter Store access"
  value       = aws_iam_policy.parameter_store_access.arn
}

output "parameter_store_policy_name" {
  description = "The name of the IAM policy for Parameter Store access"
  value       = aws_iam_policy.parameter_store_access.name
}

# Usage instructions
output "usage_instructions" {
  description = "Instructions for using the Parameter Store parameters"
  value = {
    aws_cli_commands = {
      list_all_parameters = "aws ssm get-parameters-by-path --path '${var.parameter_prefix}' --recursive --profile ${var.aws_profile}"
    }
    terraform_data_source = {
      secrets = "data.aws_ssm_parameter.secrets"
    }
  }
}

# Security information
output "security_notes" {
  description = "Important security considerations"
  sensitive   = true
  value = {
    kms_key_deletion_window = "7 days"
    parameter_types = {
      secrets = "SecureString (JSON, encrypted, auto-tiered)"
      environment = "String (unencrypted)"
    }
    access_control = "Only the developer user (${var.developer_username}) has access to these parameters"
    encryption = "All sensitive parameters are encrypted with KMS key: ${aws_kms_key.parameter_store.arn}"
    services_configured = length(local.secrets_input)
  }
}
