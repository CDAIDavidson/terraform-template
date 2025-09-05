variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-2"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Assure360"
    ManagedBy   = "Terraform"
    Environment = "production"
    Owner       = "Platform Team"
    Purpose     = "ci-cd-testing"
  }
}
