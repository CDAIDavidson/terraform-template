terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Simple provider; rely on AWS_PROFILE / environment for creds
provider "aws" {
  region = var.region
}

# Region is configurable; default to Melbourne region
variable "region" {
  type        = string
  description = "AWS region for this stack"
  default     = "ap-southeast-2"
}

# Look up the existing 'davidson-developers' group (created elsewhere)
data "aws_iam_group" "developers" {
  group_name = "davidson-developers"
}

# Define the four developers (edit usernames/tags if needed)
locals {
  developers = {
    alice = {
      username = "davidson-alice.smith"
      tags     = { CostCenter = "ENG", Team = "Platform" }
    }
    bob = {
      username = "davidson-bob.jones"
      tags     = { CostCenter = "ENG", Team = "Platform" }
    }
    carol = {
      username = "davidson-carol.ng"
      tags     = { CostCenter = "ENG", Team = "Platform" }
    }
    dan = {
      username = "davidson-dan.lee"
      tags     = { CostCenter = "ENG", Team = "Platform" }
    }
  }
}

# Create IAM users (programmatic only; no console login profiles here)
resource "aws_iam_user" "dev" {
  for_each      = local.developers
  name          = each.value.username
  force_destroy = false
  tags          = merge({ Owner = "Platform", Role = "Developer" }, each.value.tags)
}

# Add users to the developers group
resource "aws_iam_user_group_membership" "dev_membership" {
  for_each = local.developers
  user     = aws_iam_user.dev[each.key].name
  groups   = [data.aws_iam_group.developers.group_name]
}

# Create one access key per developer for CLI use
resource "aws_iam_access_key" "dev_keys" {
  for_each = local.developers
  user     = aws_iam_user.dev[each.key].name
}
