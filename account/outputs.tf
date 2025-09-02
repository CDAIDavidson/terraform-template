# Account Creation Module Outputs

output "account_id" {
  description = "The ID of the newly created AWS account"
  value       = aws_organizations_account.new_account.id
}

output "account_arn" {
  description = "The ARN of the newly created AWS account"
  value       = aws_organizations_account.new_account.arn
}

output "account_name" {
  description = "The name of the newly created AWS account"
  value       = aws_organizations_account.new_account.name
}

output "account_email" {
  description = "The email address of the newly created AWS account"
  value       = aws_organizations_account.new_account.email
}

output "account_status" {
  description = "The status of the newly created AWS account"
  value       = aws_organizations_account.new_account.status
}

output "account_joined_method" {
  description = "The method by which the account was joined to the organization"
  value       = aws_organizations_account.new_account.joined_method
}

output "account_joined_timestamp" {
  description = "The timestamp when the account was joined to the organization"
  value       = aws_organizations_account.new_account.joined_timestamp
}

output "bootstrap_role_arn" {
  description = "The ARN of the bootstrap role that can be assumed to access the account"
  value       = "arn:aws:iam::${aws_organizations_account.new_account.id}:role/OrganizationAccountAccessRole"
}
