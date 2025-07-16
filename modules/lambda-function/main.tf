# Lambda Function Module
# This module creates Lambda functions with associated IAM roles, policies, and CloudWatch log groups

locals {
  # Create IAM policies for each function based on their requirements
  lambda_iam_policies = {
    for name, config in var.functions : name => config.iam_policies
  }
}

# Create zip files for each Lambda function
data "archive_file" "lambda_zip" {
  for_each = var.functions

  type        = "zip"
  source_file = each.value.source_file
  output_path = "${path.root}/${each.key}_lambda.zip"
}

# CloudWatch Log Groups for Lambda functions
resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each = var.functions

  name              = "/aws/lambda/${var.prefix}-${var.project_name}-${each.key}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-${var.project_name}-${each.key}-logs"
  })
}

# IAM roles for Lambda execution (one per function)
resource "aws_iam_role" "lambda_execution_role" {
  for_each = var.functions

  name = "${var.prefix}-${var.project_name}-${each.key}-role"

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
    Name = "${var.prefix}-${var.project_name}-${each.key}-role"
  })
}

# IAM policy for CloudWatch Logs (shared)
resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.prefix}-${var.project_name}-lambda-logging"
  description = "IAM policy for logging from Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.prefix}-${var.project_name}-*"
      }
    ]
  })

  tags = var.common_tags
}

# Function-specific IAM policies
resource "aws_iam_policy" "lambda_function_policies" {
  for_each = local.lambda_iam_policies

  name        = "${var.prefix}-${var.project_name}-${each.key}-policy"
  description = "IAM policy for ${each.key} Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for policy in each.value : {
        Effect   = policy.effect
        Action   = policy.actions
        Resource = policy.resources
      }
    ]
  })

  tags = var.common_tags
}

# Attach logging policy to all Lambda roles
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  for_each = var.functions

  role       = aws_iam_role.lambda_execution_role[each.key].name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# Attach function-specific policies to Lambda roles
resource "aws_iam_role_policy_attachment" "lambda_policies" {
  for_each = var.functions

  role       = aws_iam_role.lambda_execution_role[each.key].name
  policy_arn = aws_iam_policy.lambda_function_policies[each.key].arn
}

# Lambda functions
resource "aws_lambda_function" "functions" {
  for_each = var.functions

  filename      = data.archive_file.lambda_zip[each.key].output_path
  function_name = "${var.prefix}-${var.project_name}-${each.key}"
  role          = aws_iam_role.lambda_execution_role[each.key].arn
  handler       = each.value.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size
  description   = each.value.description

  source_code_hash = data.archive_file.lambda_zip[each.key].output_base64sha256

  environment {
    variables = each.value.environment_vars
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policies,
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs,
  ]

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-${var.project_name}-${each.key}"
  })
}

# Lambda permissions for API Gateway to invoke functions
resource "aws_lambda_permission" "api_gateway_invoke" {
  for_each = var.functions

  statement_id  = "AllowExecutionFromAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.functions[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}
