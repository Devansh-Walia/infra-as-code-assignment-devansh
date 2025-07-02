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

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.hello_world.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.hello_world.arn
}
