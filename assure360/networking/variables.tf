variable "name" {
  description = "Workload short name"
  type        = string
  default     = "assure360-app"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "az_a" {
  description = "Availability Zone A"
  type        = string
  default     = "ap-southeast-2a"
}

variable "az_b" {
  description = "Availability Zone B"
  type        = string
  default     = "ap-southeast-2b"
}

# Auth context
variable "aws_profile" {
  description = "Named AWS profile"
  type        = string
  default     = null
}
variable "assume_role_arn" {
  description = "Optional role to assume"
  type        = string
  default     = null
}

# Networking
variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "public_cidr_a" {
  type    = string
  default = "10.10.0.0/19"
}

variable "public_cidr_b" {
  type    = string
  default = "10.10.32.0/19"
}

# Removed private_app_cidr_a - using public subnets only for dev
# Removed ecr_repo_url - using ECR repository created in this module

variable "desired_count" {
  description = "ECS desired tasks"
  type        = number
  default     = 2
}

# Security
variable "allowed_http" {
  description = "Allow HTTP 80 (true to enable redirect listener)"
  type        = bool
  default     = true
}

variable "bastion_allowed_cidr" {
  description = "Optional SSH CIDR for bastion (if you add one later)"
  type        = string
  default     = "203.0.113.10/32"
}

# Removed domain_name - using HTTP only for dev
