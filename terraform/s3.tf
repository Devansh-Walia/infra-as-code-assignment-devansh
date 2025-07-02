
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "${var.prefix}-${var.project_name}-website"

  website = {
    index_document = "index.html"
    error_document = "error.html"
  }

  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${module.s3_bucket.s3_bucket_arn}/*"
      }
    ]
  })

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  versioning = {
    enabled = true
  }

  tags = {
    Name        = "${var.prefix}-${var.project_name}-website"
    Purpose     = "Static website hosting"
    Environment = var.environment
  }
}
resource "aws_s3_object" "html_files" {
  for_each = fileset("${path.module}/../html", "*.html")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/../html/${each.value}"
  content_type = "text/html"
  etag         = filemd5("${path.module}/../html/${each.value}")

  tags = {
    Name        = each.value
    Environment = var.environment
  }
}
