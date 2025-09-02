# Stage 2 Variables - User Creation in Member Account

variable "management_region" {
  type        = string
  description = "The AWS region for the management account"
  default     = "us-east-1"
}

variable "new_account_region" {
  type        = string
  description = "The AWS region for the new member account"
  default     = "ap-southeast-2"
}

variable "member_account_id" {
  type        = string
  description = "The ID of the member account created in Stage 1"
}

variable "bootstrap_role_name" {
  type        = string
  description = "The name of the bootstrap role in the member account"
  default     = "OrganizationAccountAccessRole"
}

variable "developer_user_name" {
  type        = string
  description = "Name for the developer user"
  default     = "your-dev-user"
}

variable "admin_user_name" {
  type        = string
  description = "Name for the admin user"
  default     = "your-admin-user"
}

variable "monitor_user_name" {
  type        = string
  description = "Name for the monitor user"
  default     = "your-monitor-user"
}

variable "enable_developer_user" {
  type        = bool
  description = "Whether to create the developer user"
  default     = true
}

variable "enable_admin_user" {
  type        = bool
  description = "Whether to create the admin user"
  default     = true
}

variable "enable_monitor_user" {
  type        = bool
  description = "Whether to create the monitor user"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Common tags for all resources"
  default = {
    Project     = "YOUR_PROJECT"
    ManagedBy   = "Terraform"
    Environment = "multi-account"
    Owner       = "DevOps Team"
  }
}