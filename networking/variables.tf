# Networking Module Variables

variable "project_name" {
  type        = string
  description = "Name of the project (used for resource naming)"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "The vpc_cidr_block must be a valid CIDR block."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for the VPC (if empty, will use all available AZs in the region)"
  default     = []
  
  validation {
    condition     = length(var.availability_zones) <= 6
    error_message = "The availability_zones list cannot contain more than 6 zones."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  
  validation {
    condition     = length(var.public_subnet_cidrs) >= 1 && length(var.public_subnet_cidrs) <= 6
    error_message = "The public_subnet_cidrs list must contain between 1 and 6 CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
  
  validation {
    condition     = length(var.private_subnet_cidrs) >= 1 && length(var.private_subnet_cidrs) <= 6
    error_message = "The private_subnet_cidrs list must contain between 1 and 6 CIDR blocks."
  }
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

variable "enable_flow_logs" {
  type        = bool
  description = "Enable VPC Flow Logs"
  default     = true
}

variable "flow_log_retention_days" {
  type        = number
  description = "Number of days to retain VPC Flow Logs in CloudWatch"
  default     = 30
  
  validation {
    condition     = var.flow_log_retention_days >= 1 && var.flow_log_retention_days <= 3653
    error_message = "The flow_log_retention_days must be between 1 and 3653 days."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
