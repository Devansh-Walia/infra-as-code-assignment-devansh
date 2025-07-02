output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for website hosting"
  value       = module.s3_bucket.s3_bucket_arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for website hosting"
  value       = module.s3_bucket.s3_bucket_id
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for user storage"
  value       = aws_dynamodb_table.users.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for user storage"
  value       = aws_dynamodb_table.users.name
}

output "lambda_function_names" {
  description = "Names of the Lambda functions"
  value = {
    for key, func in aws_lambda_function.functions : key => func.function_name
  }
}

output "lambda_function_arns" {
  description = "ARNs of the Lambda functions"
  value = {
    for key, func in aws_lambda_function.functions : key => func.arn
  }
}
