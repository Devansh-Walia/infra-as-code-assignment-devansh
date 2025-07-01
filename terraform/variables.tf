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

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "iac-assignment"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
