output "new_account_id" {
  description = "The ID of the newly created AWS account"
  value       = aws_organizations_account.new_account.id
}

output "new_account_arn" {
  description = "The ARN of the newly created AWS account"
  value       = aws_organizations_account.new_account.arn
}

output "new_account_name" {
  description = "The name of the newly created AWS account"
  value       = aws_organizations_account.new_account.name
}

output "new_account_email" {
  description = "The email address of the newly created AWS account"
  value       = aws_organizations_account.new_account.email
}

output "new_account_status" {
  description = "The status of the newly created AWS account"
  value       = aws_organizations_account.new_account.status
}
