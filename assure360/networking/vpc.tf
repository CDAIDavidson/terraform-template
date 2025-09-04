resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(local.common_tags, { Name = "${var.name}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "${var.name}-igw" })
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_cidr_a
  availability_zone       = var.az_a
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, { Name = "${var.name}-public-a" })
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_cidr_b
  availability_zone       = var.az_b
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, { Name = "${var.name}-public-b" })
}

# Removed private subnet, NAT Gateway, and EIP for dev simplicity

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "${var.name}-public-rt" })
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Removed private route table and NAT routes for dev simplicity
