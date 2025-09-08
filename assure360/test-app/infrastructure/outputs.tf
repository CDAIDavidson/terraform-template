output "api_url" {
  description = "The URL of the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.test_app.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.test_app.function_name
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.test_app.arn
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.test_app.repository_url
}

output "cloudwatch_log_group" {
  description = "The CloudWatch log group name"
  value       = aws_cloudwatch_log_group.test_app.name
}

output "deployment_info" {
  description = "Deployment information for testing"
  value = {
    api_url                = "https://${aws_api_gateway_rest_api.test_app.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
    lambda_function_name   = aws_lambda_function.test_app.function_name
    ecr_repository_url     = aws_ecr_repository.test_app.repository_url
    region                 = var.aws_region
    account_id             = data.aws_caller_identity.current.account_id
  }
}

output "test_endpoints" {
  description = "Test endpoints for validation"
  value = {
    health = "https://${aws_api_gateway_rest_api.test_app.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}/health"
    hello  = "https://${aws_api_gateway_rest_api.test_app.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}/hello"
    test   = "https://${aws_api_gateway_rest_api.test_app.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}/test"
    docs   = "https://${aws_api_gateway_rest_api.test_app.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}/docs"
  }
}
