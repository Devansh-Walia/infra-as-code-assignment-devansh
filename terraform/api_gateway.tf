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

# API Gateway route for root path
resource "aws_apigatewayv2_route" "root" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# API Gateway integration with Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.hello_world.invoke_arn

  integration_method     = "POST"
  payload_format_version = "2.0"
}

# API Gateway deployment
resource "aws_apigatewayv2_deployment" "main" {
  api_id = aws_apigatewayv2_api.main.id

  depends_on = [
    aws_apigatewayv2_route.root,
    aws_apigatewayv2_integration.lambda_integration,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway stage
resource "aws_apigatewayv2_stage" "default" {
  api_id        = aws_apigatewayv2_api.main.id
  deployment_id = aws_apigatewayv2_deployment.main.id
  name          = "$default"
  auto_deploy   = true

  tags = {
    Name = "${var.prefix}-${var.project_name}-stage"
  }
}
