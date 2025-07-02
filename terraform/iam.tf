locals {
  lambda_iam_policies = {
    register-user = [
      {
        effect = "Allow"
        actions = [
          "dynamodb:PutItem"
        ]
        resources = [aws_dynamodb_table.users.arn]
      }
    ]
    verify-user = [
      {
        effect = "Allow"
        actions = [
          "dynamodb:GetItem"
        ]
        resources = [aws_dynamodb_table.users.arn]
      },
      {
        effect = "Allow"
        actions = [
          "s3:GetObject"
        ]
        resources = ["${module.s3_bucket.s3_bucket_arn}/*"]
      }
    ]
  }
}

# IAM roles for Lambda execution (one per function)
resource "aws_iam_role" "lambda_execution_role" {
  for_each = local.lambda_functions

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

  tags = {
    Name = "${var.prefix}-${var.project_name}-${each.key}-role"
  }
}

# IAM policy for CloudWatch Logs (shared)
resource "aws_iam_policy" "lambda_logging_v2" {
  name        = "${var.prefix}-${var.project_name}-lambda-logging-v2"
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
}

# Attach logging policy to all Lambda roles
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  for_each = local.lambda_functions

  role       = aws_iam_role.lambda_execution_role[each.key].name
  policy_arn = aws_iam_policy.lambda_logging_v2.arn
}

# Attach function-specific policies to Lambda roles
resource "aws_iam_role_policy_attachment" "lambda_policies" {
  for_each = local.lambda_functions

  role       = aws_iam_role.lambda_execution_role[each.key].name
  policy_arn = aws_iam_policy.lambda_function_policies[each.key].arn
}

# Lambda permissions for API Gateway to invoke functions
resource "aws_lambda_permission" "api_gateway_invoke" {
  for_each = local.lambda_functions

  statement_id  = "AllowExecutionFromAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.functions[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
