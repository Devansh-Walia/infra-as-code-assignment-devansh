# Lambda Function Module Outputs

output "functions" {
  description = "Map of Lambda function resources"
  value       = aws_lambda_function.functions
}

output "function_names" {
  description = "Map of Lambda function names"
  value = {
    for key, func in aws_lambda_function.functions : key => func.function_name
  }
}

output "function_arns" {
  description = "Map of Lambda function ARNs"
  value = {
    for key, func in aws_lambda_function.functions : key => func.arn
  }
}

output "function_invoke_arns" {
  description = "Map of Lambda function invoke ARNs"
  value = {
    for key, func in aws_lambda_function.functions : key => func.invoke_arn
  }
}

output "execution_roles" {
  description = "Map of Lambda execution role ARNs"
  value = {
    for key, role in aws_iam_role.lambda_execution_role : key => role.arn
  }
}

output "log_groups" {
  description = "Map of CloudWatch log group names"
  value = {
    for key, log_group in aws_cloudwatch_log_group.lambda_logs : key => log_group.name
  }
}
