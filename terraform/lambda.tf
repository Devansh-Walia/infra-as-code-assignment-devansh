# Lambda Functions Module
# This replaces the previous inline Lambda function resources with a reusable module

locals {
  lambda_functions = {
    register-user = {
      source_file = "${path.module}/../src/register_user.py"
      handler     = "register_user.lambda_handler"
      description = "Register new users in DynamoDB"
      environment_vars = {
        DB_TABLE_NAME = aws_dynamodb_table.users.name
      }
      iam_policies = [
        {
          effect = "Allow"
          actions = [
            "dynamodb:PutItem"
          ]
          resources = [aws_dynamodb_table.users.arn]
        }
      ]
    }
    verify-user = {
      source_file = "${path.module}/../src/verify_user.py"
      handler     = "verify_user.lambda_handler"
      description = "Verify users and return HTML from S3"
      environment_vars = {
        DB_TABLE_NAME = aws_dynamodb_table.users.name
        WEBSITE_S3    = module.s3_bucket.s3_bucket_id
      }
      iam_policies = [
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
}

# Lambda Functions Module
module "lambda_functions" {
  source = "../modules/lambda-function"

  prefix                    = var.prefix
  project_name              = var.project_name
  aws_region                = var.aws_region
  functions                 = local.lambda_functions
  api_gateway_execution_arn = aws_apigatewayv2_api.main.execution_arn

  # Optional configurations
  runtime            = "python3.9"
  timeout            = 30
  memory_size        = 128
  log_retention_days = 14

  common_tags = {
    Environment = var.environment
    Project     = "${var.prefix}-${var.project_name}"
    ManagedBy   = "terraform"
  }
}
