# API Gateway Module
# This module creates an HTTP API Gateway with multiple routes and Lambda integrations

# API Gateway HTTP API
resource "aws_apigatewayv2_api" "this" {
  name          = "${var.prefix}-${var.project_name}-api"
  protocol_type = "HTTP"
  description   = var.description

  cors_configuration {
    allow_credentials = var.cors_config.allow_credentials
    allow_headers     = var.cors_config.allow_headers
    allow_methods     = var.cors_config.allow_methods
    allow_origins     = var.cors_config.allow_origins
    expose_headers    = var.cors_config.expose_headers
    max_age           = var.cors_config.max_age
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-${var.project_name}-api"
  })
}

# API Gateway routes
resource "aws_apigatewayv2_route" "routes" {
  for_each = var.routes

  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integrations[each.key].id}"

  # Optional authorization
  authorization_type = lookup(each.value, "authorization_type", "NONE")
  authorizer_id      = lookup(each.value, "authorizer_id", null)
}

# API Gateway integrations with Lambda functions
resource "aws_apigatewayv2_integration" "lambda_integrations" {
  for_each = var.routes

  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_functions[each.value.lambda_key].invoke_arn

  integration_method     = "POST"
  payload_format_version = var.payload_format_version

  # Optional timeout configuration
  timeout_milliseconds = var.integration_timeout_ms
}

# API Gateway stage
resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  auto_deploy = var.auto_deploy

  # Optional stage configuration
  dynamic "access_log_settings" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.api_gateway_logs[0].arn
      format = jsonencode({
        requestId        = "$context.requestId"
        ip               = "$context.identity.sourceIp"
        requestTime      = "$context.requestTime"
        httpMethod       = "$context.httpMethod"
        routeKey         = "$context.routeKey"
        status           = "$context.status"
        protocol         = "$context.protocol"
        responseLength   = "$context.responseLength"
        error            = "$context.error.message"
        integrationError = "$context.integrationErrorMessage"
      })
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-${var.project_name}-stage"
  })
}

# API Gateway deployment
resource "aws_apigatewayv2_deployment" "this" {
  api_id = aws_apigatewayv2_api.this.id

  depends_on = [
    aws_apigatewayv2_route.routes,
    aws_apigatewayv2_integration.lambda_integrations,
  ]

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    redeployment = sha1(jsonencode([
      for route_key, route in var.routes : {
        route_key   = route.route_key
        lambda_key  = route.lambda_key
        lambda_hash = var.lambda_functions[route.lambda_key].source_code_hash
      }
    ]))
  }
}

# CloudWatch Log Group for API Gateway access logs (optional)
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  count = var.enable_access_logs ? 1 : 0

  name              = "/aws/apigateway/${var.prefix}-${var.project_name}-api"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-${var.project_name}-api-logs"
  })
}

# Optional: API Gateway domain name
resource "aws_apigatewayv2_domain_name" "this" {
  count = var.custom_domain != null ? 1 : 0

  domain_name = var.custom_domain.domain_name

  domain_name_configuration {
    certificate_arn = var.custom_domain.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = merge(var.common_tags, {
    Name = var.custom_domain.domain_name
  })
}

# Optional: API Gateway domain name mapping
resource "aws_apigatewayv2_api_mapping" "this" {
  count = var.custom_domain != null ? 1 : 0

  api_id      = aws_apigatewayv2_api.this.id
  domain_name = aws_apigatewayv2_domain_name.this[0].id
  stage       = aws_apigatewayv2_stage.this.id
}
