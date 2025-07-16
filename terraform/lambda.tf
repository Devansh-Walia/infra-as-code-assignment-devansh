# Lambda Functions Module
# This replaces the previous inline Lambda function resources with a reusable module

locals {
  lambda_functions = {
    register-user = {
      source_file = "${path.module}/../src/register_user.py"
      handler     = "register_user.lambda_handler"
      description = "Register new users in DynamoDB"
      environment_vars = {
        DB_TABLE_NAME = module.user_storage.dynamodb_table_name
      }
      iam_policies = [
        {
          effect = "Allow"
          actions = [
            "dynamodb:PutItem"
          ]
          resources = [module.user_storage.dynamodb_table_arn]
        }
      ]
    }
    verify-user = {
      source_file = "${path.module}/../src/verify_user.py"
      handler     = "verify_user.lambda_handler"
      description = "Verify users and return HTML from S3"
      environment_vars = {
        DB_TABLE_NAME = module.user_storage.dynamodb_table_name
        WEBSITE_S3    = module.user_storage.s3_bucket_id
      }
      iam_policies = [
        {
          effect = "Allow"
          actions = [
            "dynamodb:GetItem"
          ]
          resources = [module.user_storage.dynamodb_table_arn]
        },
        {
          effect = "Allow"
          actions = [
            "s3:GetObject"
          ]
          resources = ["${module.user_storage.s3_bucket_arn}/*"]
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
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn

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
