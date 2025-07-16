# API Gateway outputs
output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = module.api_gateway.api_gateway_url
}

# S3 outputs
output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for website hosting"
  value       = module.user_storage.s3_bucket_arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for website hosting"
  value       = module.user_storage.s3_bucket_id
}

# DynamoDB outputs
output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for user storage"
  value       = module.user_storage.dynamodb_table_arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for user storage"
  value       = module.user_storage.dynamodb_table_name
}

# Lambda outputs
output "lambda_function_names" {
  description = "Names of the Lambda functions"
  value       = module.lambda_functions.function_names
}

output "lambda_function_arns" {
  description = "ARNs of the Lambda functions"
  value       = module.lambda_functions.function_arns
}

# Module-specific outputs for advanced usage
output "api_gateway_stage_invoke_url" {
  description = "Invoke URL of the API Gateway stage"
  value       = module.api_gateway.stage_invoke_url
}

output "storage_resources" {
  description = "Combined storage resources information"
  value       = module.user_storage.storage_resources
}
