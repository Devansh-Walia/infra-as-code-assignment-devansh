data "aws_availability_zones" "available" {
  state = "available" # Only get available zones
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = var.prefix + "-iac-assignment"
      Environment = "Dev"
    }
  }
}
