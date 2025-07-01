variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "deva"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
