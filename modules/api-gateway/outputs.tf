# API Gateway Module Outputs

output "api_gateway" {
  description = "API Gateway resource"
  value       = aws_apigatewayv2_api.this
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_apigatewayv2_api.this.id
}

output "api_gateway_arn" {
  description = "ARN of the API Gateway"
  value       = aws_apigatewayv2_api.this.arn
}

output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_apigatewayv2_api.this.execution_arn
}

output "stage" {
  description = "API Gateway stage resource"
  value       = aws_apigatewayv2_stage.this
}

output "stage_id" {
  description = "ID of the API Gateway stage"
  value       = aws_apigatewayv2_stage.this.id
}

output "stage_arn" {
  description = "ARN of the API Gateway stage"
  value       = aws_apigatewayv2_stage.this.arn
}

output "stage_invoke_url" {
  description = "Invoke URL of the API Gateway stage"
  value       = aws_apigatewayv2_stage.this.invoke_url
}

output "deployment" {
  description = "API Gateway deployment resource"
  value       = aws_apigatewayv2_deployment.this
}

output "deployment_id" {
  description = "ID of the API Gateway deployment"
  value       = aws_apigatewayv2_deployment.this.id
}

output "routes" {
  description = "Map of API Gateway route resources"
  value       = aws_apigatewayv2_route.routes
}

output "integrations" {
  description = "Map of API Gateway integration resources"
  value       = aws_apigatewayv2_integration.lambda_integrations
}

output "custom_domain" {
  description = "Custom domain resource (if created)"
  value       = var.custom_domain != null ? aws_apigatewayv2_domain_name.this[0] : null
}

output "access_logs_group" {
  description = "CloudWatch log group for API Gateway access logs (if enabled)"
  value       = var.enable_access_logs ? aws_cloudwatch_log_group.api_gateway_logs[0] : null
}
