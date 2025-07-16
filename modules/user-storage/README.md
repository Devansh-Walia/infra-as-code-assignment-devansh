# User Storage Module

This module creates AWS DynamoDB table for user data storage and S3 bucket for static content hosting using both custom resources and public modules.

## Features

- **DynamoDB Table**: Flexible NoSQL database with configurable billing modes
- **Global/Local Secondary Indexes**: Support for GSI and LSI
- **Point-in-Time Recovery**: Optional backup and restore capabilities
- **DynamoDB Streams**: Optional change data capture
- **S3 Bucket**: Static website hosting using public terraform-aws-modules
- **CloudWatch Monitoring**: Optional DynamoDB throttling alarms
- **Flexible Configuration**: Extensive customization options

## Usage

```hcl
module "user_storage" {
  source = "./modules/user-storage"

  prefix       = "myapp"
  project_name = "user-service"

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
    Environment = "production"
    Project     = "user-service"
  }
}
```

## Inputs

| Name                          | Description                                                            | Type           | Default                    | Required |
| ----------------------------- | ---------------------------------------------------------------------- | -------------- | -------------------------- | :------: |
| prefix                        | Prefix for resource names                                              | `string`       | n/a                        |   yes    |
| project_name                  | Name of the project for resource naming                                | `string`       | n/a                        |   yes    |
| hash_key                      | Hash key (partition key) for the DynamoDB table                        | `string`       | n/a                        |   yes    |
| table_name                    | Name of the DynamoDB table                                             | `string`       | `"users"`                  |    no    |
| table_purpose                 | Purpose description for the DynamoDB table                             | `string`       | `"User data storage"`      |    no    |
| billing_mode                  | DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)                 | `string`       | `"PAY_PER_REQUEST"`        |    no    |
| hash_key_type                 | Type of the hash key (S, N, or B)                                      | `string`       | `"S"`                      |    no    |
| range_key                     | Range key (sort key) for the DynamoDB table                            | `string`       | `null`                     |    no    |
| range_key_type                | Type of the range key (S, N, or B)                                     | `string`       | `"S"`                      |    no    |
| read_capacity                 | Read capacity units for the table (only for PROVISIONED billing mode)  | `number`       | `5`                        |    no    |
| write_capacity                | Write capacity units for the table (only for PROVISIONED billing mode) | `number`       | `5`                        |    no    |
| additional_attributes         | Additional attributes for GSI/LSI                                      | `list(object)` | `[]`                       |    no    |
| global_secondary_indexes      | Global Secondary Indexes for the table                                 | `list(object)` | `[]`                       |    no    |
| local_secondary_indexes       | Local Secondary Indexes for the table                                  | `list(object)` | `[]`                       |    no    |
| enable_point_in_time_recovery | Enable point-in-time recovery for the table                            | `bool`         | `false`                    |    no    |
| enable_encryption             | Enable server-side encryption for the table                            | `bool`         | `false`                    |    no    |
| ttl_attribute                 | Attribute name for TTL                                                 | `string`       | `null`                     |    no    |
| stream_enabled                | Enable DynamoDB streams                                                | `bool`         | `false`                    |    no    |
| stream_view_type              | Stream view type                                                       | `string`       | `"NEW_AND_OLD_IMAGES"`     |    no    |
| enable_dynamodb_alarms        | Enable CloudWatch alarms for DynamoDB                                  | `bool`         | `false`                    |    no    |
| alarm_actions                 | List of ARNs to notify when alarm triggers                             | `list(string)` | `[]`                       |    no    |
| s3_bucket_name                | Name of the S3 bucket                                                  | `string`       | `"website"`                |    no    |
| s3_bucket_purpose             | Purpose description for the S3 bucket                                  | `string`       | `"Static website hosting"` |    no    |
| s3_force_destroy              | Force destroy the S3 bucket even if it contains objects                | `bool`         | `false`                    |    no    |
| s3_versioning_enabled         | Enable versioning for the S3 bucket                                    | `bool`         | `true`                     |    no    |
| s3_website_config             | Website configuration for the S3 bucket                                | `object`       | `null`                     |    no    |
| s3_enable_public_read         | Enable public read access for website hosting                          | `bool`         | `false`                    |    no    |
| s3_static_files               | Static files to upload to the S3 bucket                                | `map(object)`  | `{}`                       |    no    |
| common_tags                   | Common tags to apply to all resources                                  | `map(string)`  | `{}`                       |    no    |

## Outputs

| Name                       | Description                                                       |
| -------------------------- | ----------------------------------------------------------------- |
| dynamodb_table             | DynamoDB table resource                                           |
| dynamodb_table_id          | ID of the DynamoDB table                                          |
| dynamodb_table_name        | Name of the DynamoDB table                                        |
| dynamodb_table_arn         | ARN of the DynamoDB table                                         |
| dynamodb_table_stream_arn  | Stream ARN of the DynamoDB table (if streams are enabled)         |
| s3_bucket                  | S3 bucket resource from the module                                |
| s3_bucket_id               | ID of the S3 bucket                                               |
| s3_bucket_arn              | ARN of the S3 bucket                                              |
| s3_bucket_website_endpoint | Website endpoint of the S3 bucket (if website hosting is enabled) |
| s3_static_files            | Map of uploaded static files                                      |
| storage_resources          | Combined storage resources information                            |

## Examples

### Basic User Storage

```hcl
module "user_storage" {
  source = "./modules/user-storage"

  prefix       = "myapp"
  project_name = "users"
  hash_key     = "userId"
}
```

### Advanced DynamoDB with GSI

```hcl
module "user_storage" {
  source = "./modules/user-storage"

  prefix       = "ecommerce"
  project_name = "users"
  hash_key     = "userId"
  range_key    = "timestamp"

  additional_attributes = [
    {
      name = "email"
      type = "S"
    },
    {
      name = "status"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "email-index"
      hash_key        = "email"
      projection_type = "ALL"
    },
    {
      name            = "status-index"
      hash_key        = "status"
      range_key       = "timestamp"
      projection_type = "KEYS_ONLY"
    }
  ]

  enable_point_in_time_recovery = true
  enable_encryption             = true
  stream_enabled               = true
  enable_dynamodb_alarms       = true
}
```

### S3 Website Hosting

```hcl
module "user_storage" {
  source = "./modules/user-storage"

  prefix       = "company"
  project_name = "website"
  hash_key     = "id"

  s3_website_config = {
    index_document = "index.html"
    error_document = "error.html"
  }

  s3_enable_public_read = true
  s3_force_destroy     = true

  s3_static_files = {
    "index.html" = {
      source       = "${path.module}/website/index.html"
      content_type = "text/html"
    }
    "error.html" = {
      source       = "${path.module}/website/error.html"
      content_type = "text/html"
    }
    "styles.css" = {
      source       = "${path.module}/website/styles.css"
      content_type = "text/css"
    }
  }

  s3_cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]
}
```

### Production Setup with Monitoring

```hcl
module "user_storage" {
  source = "./modules/user-storage"

  prefix       = "prod"
  project_name = "app"
  hash_key     = "userId"

  # Production DynamoDB settings
  billing_mode                  = "PROVISIONED"
  read_capacity                = 100
  write_capacity               = 50
  enable_point_in_time_recovery = true
  enable_encryption            = true
  stream_enabled              = true
  enable_dynamodb_alarms      = true

  alarm_actions = [
    "arn:aws:sns:region:account:alerts-topic"
  ]

  # Production S3 settings
  s3_versioning_enabled = true
  s3_lifecycle_rules = [
    {
      id     = "delete_old_versions"
      status = "Enabled"
      noncurrent_version_expiration = {
        days = 30
      }
    }
  ]

  common_tags = {
    Environment = "production"
    Team        = "platform"
    CostCenter  = "engineering"
  }
}
```

## DynamoDB Configuration

### Billing Modes

- **PAY_PER_REQUEST** (default): Pay only for what you use
- **PROVISIONED**: Pre-allocated capacity with read/write capacity units

### Global Secondary Index Example

```hcl
global_secondary_indexes = [
  {
    name            = "email-index"
    hash_key        = "email"
    range_key       = "created_at"  # optional
    projection_type = "ALL"         # ALL, KEYS_ONLY, or INCLUDE
    read_capacity   = 5             # only for PROVISIONED billing
    write_capacity  = 5             # only for PROVISIONED billing
  }
]
```

### Stream View Types

- **KEYS_ONLY**: Only key attributes of the modified item
- **NEW_IMAGE**: Entire item after modification
- **OLD_IMAGE**: Entire item before modification
- **NEW_AND_OLD_IMAGES**: Both new and old images (default)

## S3 Configuration

### Website Hosting

```hcl
s3_website_config = {
  index_document = "index.html"
  error_document = "error.html"
}
s3_enable_public_read = true
```

### Static Files Upload

```hcl
s3_static_files = {
  "index.html" = {
    source       = "${path.module}/html/index.html"
    content_type = "text/html"
  }
  "app.js" = {
    source       = "${path.module}/js/app.js"
    content_type = "application/javascript"
  }
}
```

## Monitoring

Enable CloudWatch alarms for DynamoDB throttling:

```hcl
enable_dynamodb_alarms = true
alarm_actions = [
  "arn:aws:sns:region:account:alerts-topic"
]
```

## Best Practices

1. **DynamoDB Design**: Choose appropriate partition and sort keys
2. **Capacity Planning**: Use PAY_PER_REQUEST for unpredictable workloads
3. **Security**: Enable encryption for sensitive data
4. **Backup**: Enable point-in-time recovery for production
5. **Monitoring**: Set up CloudWatch alarms for throttling
6. **S3 Security**: Use least privilege for bucket policies
7. **Cost Optimization**: Configure lifecycle rules for S3

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- terraform-aws-modules/s3-bucket/aws ~> 4.0

## Notes

- The module uses the public terraform-aws-modules/s3-bucket/aws module for S3 resources
- DynamoDB encryption uses AWS managed keys by default
- S3 public access is blocked by default for security
- CloudWatch alarms are optional and disabled by default
