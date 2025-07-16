# User Storage Module Outputs

# DynamoDB Outputs
output "dynamodb_table" {
  description = "DynamoDB table resource"
  value       = aws_dynamodb_table.users
}

output "dynamodb_table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.users.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.users.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.users.arn
}

output "dynamodb_table_stream_arn" {
  description = "Stream ARN of the DynamoDB table (if streams are enabled)"
  value       = var.stream_enabled ? aws_dynamodb_table.users.stream_arn : null
}

output "dynamodb_table_stream_label" {
  description = "Stream label of the DynamoDB table (if streams are enabled)"
  value       = var.stream_enabled ? aws_dynamodb_table.users.stream_label : null
}

# S3 Outputs
output "s3_bucket" {
  description = "S3 bucket resource from the module"
  value       = module.s3_bucket
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_bucket_regional_domain_name
}

output "s3_bucket_website_endpoint" {
  description = "Website endpoint of the S3 bucket (if website hosting is enabled)"
  value       = var.s3_website_config != null ? module.s3_bucket.s3_bucket_website_endpoint : null
}

output "s3_bucket_website_domain" {
  description = "Website domain of the S3 bucket (if website hosting is enabled)"
  value       = var.s3_website_config != null ? module.s3_bucket.s3_bucket_website_domain : null
}

output "s3_static_files" {
  description = "Map of uploaded static files"
  value       = aws_s3_object.static_files
}

# CloudWatch Alarms Outputs
output "dynamodb_read_throttle_alarm" {
  description = "DynamoDB read throttle CloudWatch alarm (if enabled)"
  value       = var.enable_dynamodb_alarms ? aws_cloudwatch_metric_alarm.dynamodb_read_throttle[0] : null
}

output "dynamodb_write_throttle_alarm" {
  description = "DynamoDB write throttle CloudWatch alarm (if enabled)"
  value       = var.enable_dynamodb_alarms ? aws_cloudwatch_metric_alarm.dynamodb_write_throttle[0] : null
}

# Combined outputs for easy reference
output "storage_resources" {
  description = "Combined storage resources information"
  value = {
    dynamodb = {
      table_name = aws_dynamodb_table.users.name
      table_arn  = aws_dynamodb_table.users.arn
      stream_arn = var.stream_enabled ? aws_dynamodb_table.users.stream_arn : null
    }
    s3 = {
      bucket_name      = module.s3_bucket.s3_bucket_id
      bucket_arn       = module.s3_bucket.s3_bucket_arn
      website_endpoint = var.s3_website_config != null ? module.s3_bucket.s3_bucket_website_endpoint : null
    }
  }
}
