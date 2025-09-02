# Networking Module Outputs

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

# Internet Gateway Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "public_subnet_arns" {
  description = "ARNs of the public subnets"
  value       = aws_subnet.public[*].arn
}

output "private_subnet_arns" {
  description = "ARNs of the private subnets"
  value       = aws_subnet.private[*].arn
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[*].id : []
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = var.enable_nat_gateway ? aws_eip.nat[*].public_ip : []
}

output "nat_gateway_private_ips" {
  description = "Private IPs of the NAT Gateways"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[*].private_ip : []
}

# VPN Gateway Outputs
output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = var.enable_vpn_gateway ? aws_vpn_gateway.main[0].id : null
}

# Route Table Outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

# Security Group Outputs
output "default_security_group_id" {
  description = "ID of the default security group"
  value       = aws_security_group.default.id
}

# Flow Logs Outputs
output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = var.enable_flow_logs ? aws_flow_log.vpc[0].id : null
}

output "vpc_flow_log_cloudwatch_log_group" {
  description = "CloudWatch Log Group for VPC Flow Logs"
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.vpc_flow_log[0].name : null
}

# Availability Zones Output
output "availability_zones" {
  description = "List of availability zones used"
  value       = local.availability_zones
}

# Computed Values
output "subnet_count" {
  description = "Number of subnets created"
  value       = local.subnet_count
}
