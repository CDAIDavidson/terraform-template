# IAM Foundation Outputs - Groups, Policies, and Role Information

# IAM Groups information
output "admins_group_name" {
  description = "The name of the davidson-admins IAM group"
  value       = aws_iam_group.admins.name
}

output "admins_group_arn" {
  description = "The ARN of the davidson-admins IAM group"
  value       = aws_iam_group.admins.arn
}

output "developers_group_name" {
  description = "The name of the davidson-developers IAM group"
  value       = aws_iam_group.developers.name
}

output "developers_group_arn" {
  description = "The ARN of the davidson-developers IAM group"
  value       = aws_iam_group.developers.arn
}

output "support_group_name" {
  description = "The name of the davidson-support IAM group"
  value       = aws_iam_group.support.name
}

output "support_group_arn" {
  description = "The ARN of the davidson-support IAM group"
  value       = aws_iam_group.support.arn
}

# IAM Policies information
output "dev_minimal_policy_arn" {
  description = "The ARN of the DavidsonDevMinimal policy"
  value       = aws_iam_policy.dev_minimal.arn
}

output "dev_minimal_policy_name" {
  description = "The name of the DavidsonDevMinimal policy"
  value       = aws_iam_policy.dev_minimal.name
}

output "require_mfa_policy_arn" {
  description = "The ARN of the DavidsonRequireMFA policy"
  value       = aws_iam_policy.require_mfa.arn
}

output "require_mfa_policy_name" {
  description = "The name of the DavidsonRequireMFA policy"
  value       = aws_iam_policy.require_mfa.name
}

output "assume_elevated_policy_arn" {
  description = "The ARN of the DavidsonAssumeDevElevated policy"
  value       = aws_iam_policy.allow_assume_elevated.arn
}

output "assume_elevated_policy_name" {
  description = "The name of the DavidsonAssumeDevElevated policy"
  value       = aws_iam_policy.allow_assume_elevated.name
}

# IAM Role information
output "dev_elevated_role_arn" {
  description = "The ARN of the davidson-dev-elevated-role"
  value       = aws_iam_role.dev_elevated.arn
}

output "dev_elevated_role_name" {
  description = "The name of the davidson-dev-elevated-role"
  value       = aws_iam_role.dev_elevated.name
}

# Account information
output "account_id" {
  description = "The AWS account ID where resources are created"
  value       = data.aws_caller_identity.current.account_id
}

# Summary information
output "iam_foundation_summary" {
  description = "Summary of created IAM foundation"
  value = {
    groups_created = [
      aws_iam_group.admins.name,
      aws_iam_group.developers.name,
      aws_iam_group.support.name
    ]
    policies_created = [
      aws_iam_policy.dev_minimal.name,
      aws_iam_policy.require_mfa.name,
      aws_iam_policy.allow_assume_elevated.name
    ]
    role_created = aws_iam_role.dev_elevated.name
    account_id = data.aws_caller_identity.current.account_id
    region = var.region
    user_prefix = var.user_prefix
  }
}

# Group permissions summary
output "group_permissions" {
  description = "Summary of group permissions and policies"
  value = {
    davidson_admins = {
      group_name = aws_iam_group.admins.name
      policies = ["AdministratorAccess"]
      description = "Full administrative access"
    }
    davidson_developers = {
      group_name = aws_iam_group.developers.name
      policies = [
        aws_iam_policy.dev_minimal.name,
        aws_iam_policy.require_mfa.name,
        aws_iam_policy.allow_assume_elevated.name
      ]
      description = "Minimal developer rights + MFA requirement + can assume elevated role"
    }
    davidson_support = {
      group_name = aws_iam_group.support.name
      policies = [
        "ReadOnlyAccess",
        aws_iam_policy.require_mfa.name
      ]
      description = "Read-only access + MFA requirement"
    }
  }
}

# Next steps
output "next_steps" {
  description = "Instructions for next steps"
  value = {
    message = "IAM Foundation created successfully! You can now create users and assign them to groups."
    verify_groups = "aws iam list-groups --query 'Groups[?contains(GroupName, `davidson-`)]'"
    verify_policies = "aws iam list-policies --query 'Policies[?contains(PolicyName, `Davidson`)]'"
    verify_role = "aws iam get-role --role-name davidson-dev-elevated-role"
    elevated_role_assume = "aws sts assume-role --role-arn ${aws_iam_role.dev_elevated.arn} --role-session-name dev-session"
  }
}