# Local values for API Gateway module
locals {
  common_tags = {
    ManagedBy   = "Terraform"
    Project     = "${var.prefix}-${var.project_name}"
    Environment = "Dev"
  }
}

# API Gateway using custom module
module "api_gateway" {
  source = "../modules/api-gateway"

  prefix       = var.prefix
  project_name = var.project_name
  description  = "HTTP API for ${var.project_name}"

  routes = {
    register = {
      route_key  = "PUT /register"
      lambda_key = "register-user"
    }
    verify = {
      route_key  = "GET /"
      lambda_key = "verify-user"
    }
  }

  lambda_functions = {
    for key, func in module.lambda_functions.functions : key => {
      invoke_arn       = func.invoke_arn
      source_code_hash = func.source_code_hash
    }
  }

  cors_config = {
    allow_credentials = false
    allow_headers     = ["content-type", "x-amz-date", "authorization", "x-api-key"]
    allow_methods     = ["*"]
    allow_origins     = ["*"]
    expose_headers    = ["date", "keep-alive"]
    max_age           = 86400
  }

  common_tags = local.common_tags
}
