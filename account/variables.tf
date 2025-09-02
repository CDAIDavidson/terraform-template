# Account Creation Module Variables

variable "account_name" {
  type        = string
  description = "Name for the new AWS account"
  
  validation {
    condition     = length(var.account_name) >= 1 && length(var.account_name) <= 50
    error_message = "The account_name must be between 1 and 50 characters long."
  }
}

variable "account_email" {
  type        = string
  description = "Email address for the new AWS account (must be unique)"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.account_email))
    error_message = "The account_email must be a valid email address."
  }
}

variable "parent_ou_id" {
  type        = string
  description = "ID of the parent Organizational Unit (OU) where the account will be created"
  default     = null
  
  validation {
    condition     = var.parent_ou_id == null || can(regex("^ou-[a-z0-9]{4,32}-[a-z0-9]{8,32}$", var.parent_ou_id))
    error_message = "The parent_ou_id must be a valid OU ID format (ou-xxxxxxxxx-xxxxxxxxx) or null."
  }
}

variable "iam_user_access_to_billing" {
  type        = string
  description = "Whether to allow IAM users to access billing information"
  default     = "DENY"
  
  validation {
    condition     = contains(["ALLOW", "DENY"], var.iam_user_access_to_billing)
    error_message = "The iam_user_access_to_billing must be either 'ALLOW' or 'DENY'."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the new account"
  default     = {}
}
