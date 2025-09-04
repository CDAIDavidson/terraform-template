provider "aws" {
  region  = var.region
  profile = var.aws_profile
  dynamic "assume_role" {
    for_each = var.assume_role_arn == null ? [] : [1]
    content {
      role_arn     = var.assume_role_arn
      session_name = "terraform-${var.name}"
    }
  }
}

data "aws_caller_identity" "current" {}
