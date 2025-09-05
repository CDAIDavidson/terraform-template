# Stage 2 Outputs - User Creation Results

output "developer_user" {
  description = "Details of the created developer user"
  value = var.enable_developer_user ? {
    name       = aws_iam_user.developer[0].name
    arn        = aws_iam_user.developer[0].arn
    access_key = aws_iam_access_key.developer[0].id
    secret_key = aws_iam_access_key.developer[0].secret
  } : null
  sensitive = true
}

output "admin_user" {
  description = "Details of the created admin user"
  value = var.enable_admin_user ? {
    name       = aws_iam_user.admin[0].name
    arn        = aws_iam_user.admin[0].arn
    access_key = aws_iam_access_key.admin[0].id
    secret_key = aws_iam_access_key.admin[0].secret
  } : null
  sensitive = true
}

output "monitor_user" {
  description = "Details of the created monitor user"
  value = var.enable_monitor_user ? {
    name       = aws_iam_user.monitor[0].name
    arn        = aws_iam_user.monitor[0].arn
    access_key = aws_iam_access_key.monitor[0].id
    secret_key = aws_iam_access_key.monitor[0].secret
  } : null
  sensitive = true
}

output "console_login" {
  description = "Console login information for all users"
  value = {
    developer = var.enable_developer_user ? {
      username    = aws_iam_user.developer[0].name
      password    = aws_iam_user_login_profile.developer[0].password
      console_url = "https://${var.member_account_id}.signin.aws.amazon.com/console"
    } : null
    admin = var.enable_admin_user ? {
      username    = aws_iam_user.admin[0].name
      password    = aws_iam_user_login_profile.admin[0].password
      console_url = "https://${var.member_account_id}.signin.aws.amazon.com/console"
    } : null
    monitor = var.enable_monitor_user ? {
      username    = aws_iam_user.monitor[0].name
      password    = aws_iam_user_login_profile.monitor[0].password
      console_url = "https://${var.member_account_id}.signin.aws.amazon.com/console"
    } : null
  }
  sensitive = true
}

output "member_caller_identity" {
  description = "Verification that we're in the correct member account"
  value = data.aws_caller_identity.member.account_id
}

output "member_account_id" {
  description = "The ID of the member account where users were created"
  value       = var.member_account_id
}

output "bootstrap_role_arn" {
  description = "The ARN of the bootstrap role used to assume into the member account"
  value       = "arn:aws:iam::${var.member_account_id}:role/${var.bootstrap_role_name}"
}