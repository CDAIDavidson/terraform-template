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

# GitHub OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  count = var.enable_github_oidc ? 1 : 0
  
  url = "https://token.actions.githubusercontent.com"
  
  client_id_list = ["sts.amazonaws.com"]
  
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
  
  tags = merge(var.common_tags, {
    Name        = "GitHub OIDC Provider"
    Purpose     = "github-actions-oidc"
    CostCenter  = "ENG"
    Team        = "Platform"
  })
}

# GitHub Actions CI/CD Role for Development
data "aws_iam_policy_document" "github_actions_dev_trust" {
  count = var.enable_github_oidc ? 1 : 0
  
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github[0].arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        for repo in var.github_repositories : "repo:${var.github_organization}/${repo}:*"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_dev" {
  count = var.enable_github_oidc ? 1 : 0
  
  name                 = "github-actions-dev-role"
  assume_role_policy   = data.aws_iam_policy_document.github_actions_dev_trust[0].json
  max_session_duration = 3600
  
  tags = merge(var.common_tags, {
    Name        = "GitHub Actions Dev Role"
    Purpose     = "github-actions-cicd"
    CostCenter  = "ENG"
    Team        = "Platform"
    Environment = "dev"
  })
}

# GitHub Actions CI/CD Role for Production
data "aws_iam_policy_document" "github_actions_prod_trust" {
  count = var.enable_github_oidc ? 1 : 0
  
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github[0].arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        for repo in var.github_repositories : "repo:${var.github_organization}/${repo}:ref:refs/heads/main"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_prod" {
  count = var.enable_github_oidc ? 1 : 0
  
  name                 = "github-actions-prod-role"
  assume_role_policy   = data.aws_iam_policy_document.github_actions_prod_trust[0].json
  max_session_duration = 3600
  
  tags = merge(var.common_tags, {
    Name        = "GitHub Actions Prod Role"
    Purpose     = "github-actions-cicd"
    CostCenter  = "ENG"
    Team        = "Platform"
    Environment = "production"
  })
}

# GitHub Actions Policy for Development
data "aws_iam_policy_document" "github_actions_dev_policy" {
  count = var.enable_github_oidc ? 1 : 0
  
  # Terraform permissions
  statement {
    sid    = "TerraformPermissions"
    effect = "Allow"
    actions = [
      "ec2:*",
      "ecs:*",
      "ecr:*",
      "iam:*",
      "s3:*",
      "dynamodb:*",
      "cloudwatch:*",
      "logs:*",
      "events:*",
      "lambda:*",
      "apigateway:*",
      "route53:*",
      "acm:*",
      "elbv2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "rds:*",
      "secretsmanager:*",
      "ssm:*",
      "kms:*",
      "sts:GetCallerIdentity"
    ]
    resources = ["*"]
  }
  
  # S3 backend permissions
  statement {
    sid    = "S3BackendPermissions"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::assure360-terraform-state-*",
      "arn:aws:s3:::assure360-terraform-state-*/*"
    ]
  }
  
  # DynamoDB state locking
  statement {
    sid    = "DynamoDBStateLocking"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [
      "arn:aws:dynamodb:*:*:table/assure360-terraform-locks"
    ]
  }
}

resource "aws_iam_policy" "github_actions_dev_policy" {
  count = var.enable_github_oidc ? 1 : 0
  
  name        = "GitHubActionsDevPolicy"
  description = "Policy for GitHub Actions CI/CD in development environment"
  path        = "/"
  policy      = data.aws_iam_policy_document.github_actions_dev_policy[0].json
  
  tags = merge(var.common_tags, {
    Name        = "GitHub Actions Dev Policy"
    Purpose     = "github-actions-cicd"
    CostCenter  = "ENG"
    Team        = "Platform"
    Environment = "dev"
  })
}

# GitHub Actions Policy for Production (more restrictive)
data "aws_iam_policy_document" "github_actions_prod_policy" {
  count = var.enable_github_oidc ? 1 : 0
  
  # Terraform permissions (same as dev for now, but can be more restrictive)
  statement {
    sid    = "TerraformPermissions"
    effect = "Allow"
    actions = [
      "ec2:*",
      "ecs:*",
      "ecr:*",
      "iam:*",
      "s3:*",
      "dynamodb:*",
      "cloudwatch:*",
      "logs:*",
      "events:*",
      "lambda:*",
      "apigateway:*",
      "route53:*",
      "acm:*",
      "elbv2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "rds:*",
      "secretsmanager:*",
      "ssm:*",
      "kms:*",
      "sts:GetCallerIdentity"
    ]
    resources = ["*"]
  }
  
  # S3 backend permissions
  statement {
    sid    = "S3BackendPermissions"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::assure360-terraform-state-*",
      "arn:aws:s3:::assure360-terraform-state-*/*"
    ]
  }
  
  # DynamoDB state locking
  statement {
    sid    = "DynamoDBStateLocking"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [
      "arn:aws:dynamodb:*:*:table/assure360-terraform-locks"
    ]
  }
}

resource "aws_iam_policy" "github_actions_prod_policy" {
  count = var.enable_github_oidc ? 1 : 0
  
  name        = "GitHubActionsProdPolicy"
  description = "Policy for GitHub Actions CI/CD in production environment"
  path        = "/"
  policy      = data.aws_iam_policy_document.github_actions_prod_policy[0].json
  
  tags = merge(var.common_tags, {
    Name        = "GitHub Actions Prod Policy"
    Purpose     = "github-actions-cicd"
    CostCenter  = "ENG"
    Team        = "Platform"
    Environment = "production"
  })
}

# Attach policies to roles
resource "aws_iam_role_policy_attachment" "github_actions_dev_policy_attach" {
  count = var.enable_github_oidc ? 1 : 0
  
  role       = aws_iam_role.github_actions_dev[0].name
  policy_arn = aws_iam_policy.github_actions_dev_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "github_actions_prod_policy_attach" {
  count = var.enable_github_oidc ? 1 : 0
  
  role       = aws_iam_role.github_actions_prod[0].name
  policy_arn = aws_iam_policy.github_actions_prod_policy[0].arn
}