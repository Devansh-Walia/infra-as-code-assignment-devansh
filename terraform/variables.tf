variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-central-1"
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "deva-iac-assignment"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
