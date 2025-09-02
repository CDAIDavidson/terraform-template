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

# VPC Configuration Variables
variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for the VPC"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway for private subnets"
  default     = true
}

variable "enable_vpn_gateway" {
  type        = bool
  description = "Enable VPN Gateway for the VPC"
  default     = false
}
