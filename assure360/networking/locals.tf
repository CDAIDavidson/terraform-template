locals {
  common_tags = {
    Application = var.name
    Environment = "dev"
    ManagedBy   = "Terraform"
    AccountId   = data.aws_caller_identity.current.account_id
  }
}
