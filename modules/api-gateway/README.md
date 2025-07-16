# API Gateway Module

This module creates an AWS HTTP API Gateway with multiple routes, Lambda integrations, and optional features like access logging and custom domains.

## Features

- **HTTP API Gateway**: Modern, high-performance API Gateway
- **Multiple Routes**: Support for multiple API routes with `for_each`
- **Lambda Integration**: Seamless integration with Lambda functions
- **CORS Configuration**: Flexible CORS settings
- **Access Logging**: Optional CloudWatch access logs
- **Custom Domains**: Optional custom domain support
- **Auto Deployment**: Automatic redeployment on Lambda changes

## Usage

```hcl
module "api_gateway" {
  source = "./modules/api-gateway"

  prefix       = "myapp"
  project_name = "user-service"
  description  = "User management API"

  routes = {
    register = {
      route_key  = "PUT /register"
      lambda_key = "register-user"
    }
    verify = {
      route_key  = "GET /"
      lambda_key = "verify-user"
    }
    health = {
      route_key  = "GET /health"
      lambda_key = "health-check"
    }
  }

  lambda_functions = module.lambda_functions.function_invoke_arns

  # Optional configurations
  cors_config = {
    allow_credentials = false
    allow_headers     = ["content-type", "authorization"]
    allow_methods     = ["GET", "POST", "PUT", "DELETE"]
    allow_origins     = ["https://myapp.com"]
    expose_headers    = ["date"]
    max_age           = 3600
  }

  enable_access_logs = true
  log_retention_days = 30

  common_tags = {
    Environment = "production"
    Project     = "user-service"
  }
}
```

## Inputs

| Name                   | Description                                                  | Type          | Default              | Required |
| ---------------------- | ------------------------------------------------------------ | ------------- | -------------------- | :------: |
| prefix                 | Prefix for resource names                                    | `string`      | n/a                  |   yes    |
| project_name           | Name of the project for resource naming                      | `string`      | n/a                  |   yes    |
| routes                 | Map of API Gateway routes to create                          | `map(object)` | n/a                  |   yes    |
| lambda_functions       | Map of Lambda function resources from lambda-function module | `map(object)` | n/a                  |   yes    |
| description            | Description for the API Gateway                              | `string`      | `"HTTP API Gateway"` |    no    |
| cors_config            | CORS configuration for the API Gateway                       | `object`      | See defaults         |    no    |
| stage_name             | Name of the API Gateway stage                                | `string`      | `"$default"`         |    no    |
| auto_deploy            | Whether to automatically deploy the API Gateway stage        | `bool`        | `true`               |    no    |
| payload_format_version | Payload format version for Lambda integrations               | `string`      | `"2.0"`              |    no    |
| integration_timeout_ms | Integration timeout in milliseconds                          | `number`      | `30000`              |    no    |
| enable_access_logs     | Whether to enable API Gateway access logs                    | `bool`        | `false`              |    no    |
| log_retention_days     | CloudWatch log retention in days                             | `number`      | `14`                 |    no    |
| custom_domain          | Custom domain configuration for API Gateway                  | `object`      | `null`               |    no    |
| common_tags            | Common tags to apply to all resources                        | `map(string)` | `{}`                 |    no    |

## Outputs

| Name                      | Description                                                   |
| ------------------------- | ------------------------------------------------------------- |
| api_gateway               | API Gateway resource                                          |
| api_gateway_id            | ID of the API Gateway                                         |
| api_gateway_arn           | ARN of the API Gateway                                        |
| api_gateway_url           | URL of the API Gateway                                        |
| api_gateway_execution_arn | Execution ARN of the API Gateway                              |
| stage                     | API Gateway stage resource                                    |
| stage_id                  | ID of the API Gateway stage                                   |
| stage_arn                 | ARN of the API Gateway stage                                  |
| stage_invoke_url          | Invoke URL of the API Gateway stage                           |
| deployment                | API Gateway deployment resource                               |
| deployment_id             | ID of the API Gateway deployment                              |
| routes                    | Map of API Gateway route resources                            |
| integrations              | Map of API Gateway integration resources                      |
| custom_domain             | Custom domain resource (if created)                           |
| access_logs_group         | CloudWatch log group for API Gateway access logs (if enabled) |

## Route Configuration

Each route in the `routes` map should have the following structure:

```hcl
{
  route_key          = string           # HTTP method and path (e.g., "GET /users")
  lambda_key         = string           # Key to reference Lambda function
  authorization_type = optional(string) # Authorization type (default: "NONE")
  authorizer_id      = optional(string) # Authorizer ID (if using custom auth)
}
```

## CORS Configuration

The default CORS configuration allows all origins and methods:

```hcl
cors_config = {
  allow_credentials = false
  allow_headers     = ["content-type", "x-amz-date", "authorization", "x-api-key"]
  allow_methods     = ["*"]
  allow_origins     = ["*"]
  expose_headers    = ["date", "keep-alive"]
  max_age           = 86400
}
```

## Custom Domain Configuration

To use a custom domain:

```hcl
custom_domain = {
  domain_name     = "api.myapp.com"
  certificate_arn = "arn:aws:acm:region:account:certificate/cert-id"
}
```

## Access Logging

Enable access logging to monitor API usage:

```hcl
enable_access_logs = true
log_retention_days = 30
```

Log format includes:

- Request ID
- Source IP
- Request time
- HTTP method
- Route key
- Response status
- Protocol
- Response length
- Error messages

## Examples

### Basic API Gateway

```hcl
module "api_gateway" {
  source = "./modules/api-gateway"

  prefix       = "myapp"
  project_name = "api"

  routes = {
    root = {
      route_key  = "GET /"
      lambda_key = "hello-world"
    }
  }

  lambda_functions = {
    hello-world = {
      invoke_arn       = "arn:aws:lambda:region:account:function:hello-world"
      source_code_hash = "abc123"
    }
  }
}
```

### API with Multiple Routes and CORS

```hcl
module "api_gateway" {
  source = "./modules/api-gateway"

  prefix       = "ecommerce"
  project_name = "api"
  description  = "E-commerce API Gateway"

  routes = {
    products_list = {
      route_key  = "GET /products"
      lambda_key = "list-products"
    }
    products_get = {
      route_key  = "GET /products/{id}"
      lambda_key = "get-product"
    }
    products_create = {
      route_key  = "POST /products"
      lambda_key = "create-product"
    }
  }

  lambda_functions = module.lambda_functions.function_invoke_arns

  cors_config = {
    allow_credentials = true
    allow_headers     = ["content-type", "authorization"]
    allow_methods     = ["GET", "POST", "PUT", "DELETE"]
    allow_origins     = ["https://shop.example.com"]
    expose_headers    = ["x-total-count"]
    max_age           = 3600
  }

  enable_access_logs = true
}
```

### API with Custom Domain

```hcl
module "api_gateway" {
  source = "./modules/api-gateway"

  prefix       = "company"
  project_name = "public-api"

  routes = {
    v1_users = {
      route_key  = "GET /v1/users"
      lambda_key = "users-handler"
    }
  }

  lambda_functions = module.lambda_functions.function_invoke_arns

  custom_domain = {
    domain_name     = "api.company.com"
    certificate_arn = data.aws_acm_certificate.api_cert.arn
  }
}
```

## Integration with Lambda Module

This module is designed to work seamlessly with the lambda-function module:

```hcl
module "lambda_functions" {
  source = "./modules/lambda-function"
  # ... lambda configuration
}

module "api_gateway" {
  source = "./modules/api-gateway"

  # Pass Lambda function outputs directly
  lambda_functions = module.lambda_functions.function_invoke_arns

  routes = {
    endpoint1 = {
      route_key  = "GET /endpoint1"
      lambda_key = "function1"  # Must match key in lambda_functions module
    }
  }
}
```

## Best Practices

1. **Route Organization**: Use descriptive route keys that reflect the API structure
2. **CORS Security**: Configure CORS restrictively for production environments
3. **Access Logging**: Enable access logs for production APIs
4. **Custom Domains**: Use custom domains for production APIs
5. **Monitoring**: Set up CloudWatch alarms for API metrics
6. **Versioning**: Consider API versioning in your route structure

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- Lambda functions must exist before creating API Gateway
- For custom domains: ACM certificate must exist in the same region

## Notes

- The module automatically handles redeployment when Lambda function code changes
- Stage name defaults to `$default` which is the recommended approach for HTTP APIs
- Integration timeout is set to 30 seconds by default (API Gateway maximum)
- Access logs are disabled by default to reduce costs
