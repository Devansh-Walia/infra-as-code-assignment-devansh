locals {
  lambda_functions = {
    register-user = {
      source_file = "${path.module}/../src/register_user.py"
      handler     = "register_user.lambda_handler"
      description = "Register new users in DynamoDB"
      environment_vars = {
        DB_TABLE_NAME = aws_dynamodb_table.users.name
      }
    }
    verify-user = {
      source_file = "${path.module}/../src/verify_user.py"
      handler     = "verify_user.lambda_handler"
      description = "Verify users and return HTML from S3"
      environment_vars = {
        DB_TABLE_NAME = aws_dynamodb_table.users.name
        WEBSITE_S3    = module.s3_bucket.s3_bucket_id
      }
    }
  }
}

# Create zip files for each Lambda function
data "archive_file" "lambda_zip" {
  for_each = local.lambda_functions

  type        = "zip"
  source_file = each.value.source_file
  output_path = "${path.module}/${each.key}_lambda.zip"
}

# CloudWatch Log Groups for Lambda functions
resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each = local.lambda_functions

  name              = "/aws/lambda/${var.prefix}-${var.project_name}-${each.key}"
  retention_in_days = 14

  tags = {
    Name = "${var.prefix}-${var.project_name}-${each.key}-logs"
  }
}

# Lambda functions
resource "aws_lambda_function" "functions" {
  for_each = local.lambda_functions

  filename      = data.archive_file.lambda_zip[each.key].output_path
  function_name = "${var.prefix}-${var.project_name}-${each.key}"
  role          = aws_iam_role.lambda_execution_role[each.key].arn
  handler       = each.value.handler
  runtime       = "python3.9"
  timeout       = 30
  description   = each.value.description

  source_code_hash = data.archive_file.lambda_zip[each.key].output_base64sha256

  environment {
    variables = each.value.environment_vars
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policies,
    aws_cloudwatch_log_group.lambda_logs,
  ]

  tags = {
    Name = "${var.prefix}-${var.project_name}-${each.key}"
  }
}
