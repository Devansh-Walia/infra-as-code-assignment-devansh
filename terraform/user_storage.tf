# User Storage using custom module (replaces dynamodb.tf and s3.tf)
module "user_storage" {
  source = "../modules/user-storage"

  prefix       = var.prefix
  project_name = var.project_name

  # DynamoDB Configuration
  hash_key = "userId"

  # S3 Configuration
  s3_website_config = {
    index_document = "index.html"
    error_document = "error.html"
  }
  s3_enable_public_read = true

  s3_static_files = {
    "index.html" = {
      source       = "${path.module}/../html/index.html"
      content_type = "text/html"
    }
    "error.html" = {
      source       = "${path.module}/../html/error.html"
      content_type = "text/html"
    }
  }

  common_tags = {
    ManagedBy   = "Terraform"
    Project     = "${var.prefix}-${var.project_name}"
    Environment = var.environment
  }
}
