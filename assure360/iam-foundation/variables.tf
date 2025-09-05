# Region is configurable; default to Melbourne region
variable "region" {
  type        = string
  description = "AWS region for this stack"
  default     = "ap-southeast-2"
}

# Common tags for all resources
variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default = {
    Project     = "Assure360"
    ManagedBy   = "Terraform"
    Environment = "production"
    Owner       = "Platform Team"
  }
}

# Prefix for all IAM usernames
variable "user_prefix" {
  description = "Prefix for all IAM usernames"
  type        = string
  default     = "davidson-"
}

# GitHub OIDC Configuration
variable "github_organization" {
  description = "GitHub organization name for OIDC trust"
  type        = string
  default     = ""
}

variable "github_repositories" {
  description = "List of GitHub repositories that can assume the CI/CD roles"
  type        = list(string)
  default     = []
}

variable "enable_github_oidc" {
  description = "Enable GitHub OIDC provider and CI/CD roles"
  type        = bool
  default     = false
}