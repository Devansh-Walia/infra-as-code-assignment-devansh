# API Gateway Module Variables

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
}

variable "description" {
  description = "Description for the API Gateway"
  type        = string
  default     = "HTTP API Gateway"
}

variable "routes" {
  description = "Map of API Gateway routes to create"
  type = map(object({
    route_key          = string
    lambda_key         = string
    authorization_type = optional(string)
    authorizer_id      = optional(string)
  }))
}

variable "lambda_functions" {
  description = "Map of Lambda function resources from lambda-function module"
  type = map(object({
    invoke_arn       = string
    source_code_hash = string
  }))
}

variable "cors_config" {
  description = "CORS configuration for the API Gateway"
  type = object({
    allow_credentials = bool
    allow_headers     = list(string)
    allow_methods     = list(string)
    allow_origins     = list(string)
    expose_headers    = list(string)
    max_age           = number
  })
  default = {
    allow_credentials = false
    allow_headers     = ["content-type", "x-amz-date", "authorization", "x-api-key"]
    allow_methods     = ["*"]
    allow_origins     = ["*"]
    expose_headers    = ["date", "keep-alive"]
    max_age           = 86400
  }
}

variable "stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "$default"
}

variable "auto_deploy" {
  description = "Whether to automatically deploy the API Gateway stage"
  type        = bool
  default     = true
}

variable "payload_format_version" {
  description = "Payload format version for Lambda integrations"
  type        = string
  default     = "2.0"
}

variable "integration_timeout_ms" {
  description = "Integration timeout in milliseconds"
  type        = number
  default     = 30000
}

variable "enable_access_logs" {
  description = "Whether to enable API Gateway access logs"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "custom_domain" {
  description = "Custom domain configuration for API Gateway"
  type = object({
    domain_name     = string
    certificate_arn = string
  })
  default = null
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
