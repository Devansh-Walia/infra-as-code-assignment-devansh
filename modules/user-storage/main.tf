# User Storage Module
# This module creates DynamoDB table for user data and S3 bucket for static content

# DynamoDB table for user storage
resource "aws_dynamodb_table" "users" {
  name           = "${var.prefix}-${var.project_name}-${var.table_name}"
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  range_key      = var.range_key
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  # Hash key attribute
  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  # Range key attribute (optional)
  dynamic "attribute" {
    for_each = var.range_key != null ? [1] : []
    content {
      name = var.range_key
      type = var.range_key_type
    }
  }

  # Additional attributes for GSI/LSI
  dynamic "attribute" {
    for_each = var.additional_attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # Global Secondary Indexes
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = global_secondary_index.value.range_key
      projection_type = global_secondary_index.value.projection_type

      read_capacity  = var.billing_mode == "PROVISIONED" ? global_secondary_index.value.read_capacity : null
      write_capacity = var.billing_mode == "PROVISIONED" ? global_secondary_index.value.write_capacity : null
    }
  }

  # Local Secondary Indexes
  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    content {
      name            = local_secondary_index.value.name
      range_key       = local_secondary_index.value.range_key
      projection_type = local_secondary_index.value.projection_type
    }
  }

  # Point-in-time recovery
  dynamic "point_in_time_recovery" {
    for_each = var.enable_point_in_time_recovery ? [1] : []
    content {
      enabled = true
    }
  }

  # Server-side encryption
  dynamic "server_side_encryption" {
    for_each = var.enable_encryption ? [1] : []
    content {
      enabled = true
    }
  }

  # TTL configuration
  dynamic "ttl" {
    for_each = var.ttl_attribute != null ? [1] : []
    content {
      attribute_name = var.ttl_attribute
      enabled        = true
    }
  }

  # Stream configuration
  dynamic "stream_specification" {
    for_each = var.stream_enabled ? [1] : []
    content {
      stream_enabled   = true
      stream_view_type = var.stream_view_type
    }
  }

  tags = merge(var.common_tags, {
    Name    = "${var.prefix}-${var.project_name}-${var.table_name}"
    Purpose = var.table_purpose
  })
}

# S3 bucket using public module
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "${var.prefix}-${var.project_name}-${var.s3_bucket_name}"

  # Bucket configuration
  force_destroy = var.s3_force_destroy

  # Versioning
  versioning = {
    enabled = var.s3_versioning_enabled
  }

  # Website configuration
  website = var.s3_website_config != null ? {
    index_document = var.s3_website_config.index_document
    error_document = var.s3_website_config.error_document
  } : {}

  # Public access block
  block_public_acls       = var.s3_block_public_acls
  block_public_policy     = var.s3_block_public_policy
  ignore_public_acls      = var.s3_ignore_public_acls
  restrict_public_buckets = var.s3_restrict_public_buckets

  # CORS configuration
  cors_rule = var.s3_cors_rules

  # Lifecycle configuration
  lifecycle_rule = var.s3_lifecycle_rules

  # Server-side encryption
  server_side_encryption_configuration = var.s3_encryption_config

  # Logging
  logging = var.s3_logging_config

  tags = merge(var.common_tags, {
    Name    = "${var.prefix}-${var.project_name}-${var.s3_bucket_name}"
    Purpose = var.s3_bucket_purpose
  })
}

# S3 bucket policy for public read access (if website hosting is enabled)
resource "aws_s3_bucket_policy" "website_policy" {
  count = var.s3_website_config != null && var.s3_enable_public_read ? 1 : 0

  bucket = module.s3_bucket.s3_bucket_id

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

  depends_on = [module.s3_bucket]
}

# S3 objects for static content
resource "aws_s3_object" "static_files" {
  for_each = var.s3_static_files

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.key
  source       = each.value.source
  content_type = each.value.content_type
  etag         = filemd5(each.value.source)

  tags = merge(var.common_tags, {
    Name = each.key
  })

  depends_on = [module.s3_bucket]
}

# CloudWatch alarms for DynamoDB
resource "aws_cloudwatch_metric_alarm" "dynamodb_read_throttle" {
  count = var.enable_dynamodb_alarms ? 1 : 0

  alarm_name          = "${var.prefix}-${var.project_name}-${var.table_name}-read-throttle"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ReadThrottledEvents"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors DynamoDB read throttling"
  alarm_actions       = var.alarm_actions

  dimensions = {
    TableName = aws_dynamodb_table.users.name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_write_throttle" {
  count = var.enable_dynamodb_alarms ? 1 : 0

  alarm_name          = "${var.prefix}-${var.project_name}-${var.table_name}-write-throttle"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "WriteThrottledEvents"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors DynamoDB write throttling"
  alarm_actions       = var.alarm_actions

  dimensions = {
    TableName = aws_dynamodb_table.users.name
  }

  tags = var.common_tags
}
