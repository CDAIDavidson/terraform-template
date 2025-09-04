# Simple provider; rely on AWS_PROFILE / environment for creds
provider "aws" {
  region = var.region
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# IAM Groups
resource "aws_iam_group" "admins" {
  name = "davidson-admins"
  path = "/"
}

resource "aws_iam_group" "developers" {
  name = "davidson-developers"
  path = "/"
}

resource "aws_iam_group" "support" {
  name = "davidson-support"
  path = "/"
}

# Attach managed policies
resource "aws_iam_group_policy_attachment" "admins_admin" {
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "support_ro" {
  group      = aws_iam_group.support.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# MFA requirement policy
data "aws_iam_policy_document" "require_mfa" {
  statement {
    sid     = "DenyIfNoMFA"
    effect  = "Deny"
    actions = ["*"]
    resources = ["*"]
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }
}

resource "aws_iam_policy" "require_mfa" {
  name        = "DavidsonRequireMFA"
  description = "Deny all actions if MFA is not present"
  path        = "/"
  policy      = data.aws_iam_policy_document.require_mfa.json
  
  tags = merge(var.common_tags, {
    Name        = "Davidson Require MFA Policy"
    Purpose     = "security-mfa"
    CostCenter  = "ENG"
    Team        = "Platform"
  })
}

resource "aws_iam_group_policy_attachment" "dev_mfa" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.require_mfa.arn
}

resource "aws_iam_group_policy_attachment" "support_mfa" {
  group      = aws_iam_group.support.name
  policy_arn = aws_iam_policy.require_mfa.arn
}

# Developer minimal policy
data "aws_iam_policy_document" "dev_minimal" {
  statement {
    sid     = "CommonRead"
    effect  = "Allow"
    actions = [
      "cloudwatch:*",
      "logs:*",
      "events:*",
      "xray:*",
      "ec2:Describe*",
      "rds:Describe*",
      "ecr:Describe*",
      "ecr:Get*",
      "lambda:Get*",
      "lambda:List*",
      "ssm:Describe*",
      "ssm:Get*",
      "ssm:List*",
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation"
    ]
    resources = ["*"]
  }
  
  statement {
    sid     = "DeployOps"
    effect  = "Allow"
    actions = [
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:InvokeFunction",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = ["*"]
  }
  
  statement {
    sid     = "ProjectBucketsRW"
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::assure360-*",
      "arn:aws:s3:::assure360-*/*"
    ]
  }
}

resource "aws_iam_policy" "dev_minimal" {
  name        = "DavidsonDevMinimal"
  description = "Practical developer day-to-day rights (no admin)"
  path        = "/"
  policy      = data.aws_iam_policy_document.dev_minimal.json
  
  tags = merge(var.common_tags, {
    Name        = "Davidson Dev Minimal Policy"
    Purpose     = "developer-permissions"
    CostCenter  = "ENG"
    Team        = "Platform"
  })
}

resource "aws_iam_group_policy_attachment" "dev_minimal_attach" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.dev_minimal.arn
}

# Optional elevated role
data "aws_iam_policy_document" "dev_elevated_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role" "dev_elevated" {
  name                 = "davidson-dev-elevated-role"
  assume_role_policy   = data.aws_iam_policy_document.dev_elevated_trust.json
  max_session_duration = 3600
  
  tags = merge(var.common_tags, {
    Name        = "Davidson Dev Elevated Role"
    Purpose     = "elevated-developer-access"
    CostCenter  = "ENG"
    Team        = "Platform"
  })
}

resource "aws_iam_role_policy_attachment" "dev_elevated_poweruser" {
  role       = aws_iam_role.dev_elevated.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# Let developers assume the elevated role
data "aws_iam_policy_document" "allow_assume_elevated" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.dev_elevated.arn]
  }
}

resource "aws_iam_policy" "allow_assume_elevated" {
  name        = "DavidsonAssumeDevElevated"
  description = "Allows assuming the davidson-dev-elevated-role"
  path        = "/"
  policy      = data.aws_iam_policy_document.allow_assume_elevated.json
  
  tags = merge(var.common_tags, {
    Name        = "Davidson Assume Dev Elevated Policy"
    Purpose     = "role-assumption"
    CostCenter  = "ENG"
    Team        = "Platform"
  })
}

resource "aws_iam_group_policy_attachment" "dev_can_assume" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.allow_assume_elevated.arn
}