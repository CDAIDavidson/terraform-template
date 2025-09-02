# Essential variables for creating a new AWS account

variable "account_name" {
  type        = string
  description = "Name for the new AWS account"
}

variable "account_email" {
  type        = string
  description = "Email address for the new AWS account (must be unique)"
}

variable "parent_ou_id" {
  type        = string
  description = "ID of the parent Organizational Unit (OU) where the account will be created"
  default     = null
}

variable "iam_user_access_to_billing" {
  type        = string
  description = "Whether to allow IAM users to access billing information"
  default     = "DENY"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the new account"
  default     = {}
}
