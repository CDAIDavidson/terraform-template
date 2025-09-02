# Stage 3 Variables - Parameter Store Configuration

variable "management_region" {
  type        = string
  description = "The AWS region for the management account"
}

variable "member_account_region" {
  type        = string
  description = "The AWS region for the member account"
}

variable "member_account_id" {
  type        = string
  description = "The ID of the member account created in Stage 1"
}

variable "bootstrap_role_name" {
  type        = string
  description = "The name of the bootstrap role in the member account"
}

variable "developer_username" {
  type        = string
  description = "The username of the developer created in Stage 2"
}

variable "parameter_prefix" {
  type        = string
  description = "The prefix for all Parameter Store parameters"
}

# Service credentials - loaded from .env file using TF_VAR_ pattern
variable "secrets" {
  type = map(any)
  description = "Service credentials loaded from .env file (TF_VAR_secrets)"
  # Note: Cannot mark as sensitive when using in for_each
}

variable "environment" {
  type        = string
  description = "The environment name (dev, staging, prod)"
}

variable "aws_profile" {
  type        = string
  description = "AWS profile name for CLI commands and outputs"
}


