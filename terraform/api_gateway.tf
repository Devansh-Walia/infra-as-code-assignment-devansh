locals {
  api_routes = {
    register = {
      route_key  = "PUT /register"
      lambda_key = "register-user"
    }
    verify = {
      route_key  = "GET /"
      lambda_key = "verify-user"
    }
  }
}

# API Gateway HTTP API
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.prefix}-${var.project_name}-api"
  protocol_type = "HTTP"
  description   = "HTTP API for ${var.project_name}"

  cors_configuration {
    allow_credentials = false
    allow_headers     = ["content-type", "x-amz-date", "authorization", "x-api-key"]
    allow_methods     = ["*"]
    allow_origins     = ["*"]
    expose_headers    = ["date", "keep-alive"]
    max_age           = 86400
  }

  tags = {
    Name = "${var.prefix}-${var.project_name}-api"
  }
}

# API Gateway routes
resource "aws_apigatewayv2_route" "routes" {
  for_each = local.api_routes

  api_id    = aws_apigatewayv2_api.main.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integrations[each.key].id}"
}

# API Gateway integrations with Lambda functions
resource "aws_apigatewayv2_integration" "lambda_integrations" {
  for_each = local.api_routes

  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  integration_uri  = module.lambda_functions.function_invoke_arns[each.value.lambda_key]

  integration_method     = "POST"
  payload_format_version = "2.0"
}

# API Gateway deployment
resource "aws_apigatewayv2_deployment" "main" {
  api_id = aws_apigatewayv2_api.main.id

  depends_on = [
    aws_apigatewayv2_route.routes,
    aws_apigatewayv2_integration.lambda_integrations,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Name = "${var.prefix}-${var.project_name}-stage"
  }
}
