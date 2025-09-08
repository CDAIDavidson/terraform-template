# Provider configuration
provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ECR Repository for Docker images
resource "aws_ecr_repository" "test_app" {
  name                 = "assure360-test-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.common_tags, {
    Name        = "assure360-test-app"
    Purpose     = "ci-cd-testing"
    CostCenter  = "ENG"
    Team        = "Platform"
  })
}

# ECR lifecycle policy
resource "aws_ecr_lifecycle_policy" "test_app" {
  repository = aws_ecr_repository.test_app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution" {
  name = "assure360-test-app-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name        = "assure360-test-app-lambda-role"
    Purpose     = "ci-cd-testing"
    CostCenter  = "ENG"
    Team        = "Platform"
  })
}

# Attach basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function
resource "aws_lambda_function" "test_app" {
  function_name = "assure360-test-app"
  role          = aws_iam_role.lambda_execution.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.test_app.repository_url}:latest"
  timeout       = 30
  memory_size   = 512

  environment {
    variables = {
      ENVIRONMENT = "production"
    }
  }

  tags = merge(var.common_tags, {
    Name        = "assure360-test-app"
    Purpose     = "ci-cd-testing"
    CostCenter  = "ENG"
    Team        = "Platform"
  })

  depends_on = [
    aws_ecr_repository.test_app
  ]
}

# API Gateway
resource "aws_api_gateway_rest_api" "test_app" {
  name        = "assure360-test-app-api"
  description = "API Gateway for Assure360 Test App"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(var.common_tags, {
    Name        = "assure360-test-app-api"
    Purpose     = "ci-cd-testing"
    CostCenter  = "ENG"
    Team        = "Platform"
  })
}

# API Gateway method on root (ANY)
resource "aws_api_gateway_method" "root_any" {
  rest_api_id   = aws_api_gateway_rest_api.test_app.id
  resource_id   = aws_api_gateway_rest_api.test_app.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

# API Gateway Lambda proxy integration on root (ANY)
resource "aws_api_gateway_integration" "root_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.test_app.id
  resource_id             = aws_api_gateway_rest_api.test_app.root_resource_id
  http_method             = aws_api_gateway_method.root_any.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.test_app.arn}/invocations"
}

# Greedy proxy resource to route all subpaths to Lambda (e.g., /health, /hello)
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.test_app.id
  parent_id   = aws_api_gateway_rest_api.test_app.root_resource_id
  path_part   = "{proxy+}"
}

# ANY method on the greedy proxy resource
resource "aws_api_gateway_method" "proxy_any" {
  rest_api_id   = aws_api_gateway_rest_api.test_app.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

# Lambda proxy integration for the greedy proxy
resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.test_app.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_any.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.test_app.arn}/invocations"
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "test_app" {
  depends_on = [aws_api_gateway_integration.root_proxy, aws_api_gateway_integration.proxy_integration]
  rest_api_id = aws_api_gateway_rest_api.test_app.id

  # Force redeploy when routes/integrations change
  triggers = {
    redeploy_hash = sha1(jsonencode({
      root_integration  = aws_api_gateway_integration.root_proxy.id
      proxy_integration = aws_api_gateway_integration.proxy_integration.id
      methods = {
        root  = aws_api_gateway_method.root_any.id
        proxy = aws_api_gateway_method.proxy_any.id
      }
    }))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  rest_api_id   = aws_api_gateway_rest_api.test_app.id
  deployment_id = aws_api_gateway_deployment.test_app.id
  stage_name    = "prod"
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_app.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.test_app.execution_arn}/*/*"
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "test_app" {
  name              = "/aws/lambda/${aws_lambda_function.test_app.function_name}"
  retention_in_days = 14

  tags = merge(var.common_tags, {
    Name        = "assure360-test-app-logs"
    Purpose     = "ci-cd-testing"
    CostCenter  = "ENG"
    Team        = "Platform"
  })
}
