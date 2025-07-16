variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "deva"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "iac-assignment"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}
