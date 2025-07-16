# User Storage Module Variables

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
}

# DynamoDB Variables
variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "users"
}

variable "table_purpose" {
  description = "Purpose description for the DynamoDB table"
  type        = string
  default     = "User data storage"
}

variable "billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "Billing mode must be either PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "hash_key" {
  description = "Hash key (partition key) for the DynamoDB table"
  type        = string
}

variable "hash_key_type" {
  description = "Type of the hash key (S, N, or B)"
  type        = string
  default     = "S"
  validation {
    condition     = contains(["S", "N", "B"], var.hash_key_type)
    error_message = "Hash key type must be S (String), N (Number), or B (Binary)."
  }
}

variable "range_key" {
  description = "Range key (sort key) for the DynamoDB table"
  type        = string
  default     = null
}

variable "range_key_type" {
  description = "Type of the range key (S, N, or B)"
  type        = string
  default     = "S"
  validation {
    condition     = contains(["S", "N", "B"], var.range_key_type)
    error_message = "Range key type must be S (String), N (Number), or B (Binary)."
  }
}

variable "read_capacity" {
  description = "Read capacity units for the table (only for PROVISIONED billing mode)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units for the table (only for PROVISIONED billing mode)"
  type        = number
  default     = 5
}

variable "additional_attributes" {
  description = "Additional attributes for GSI/LSI"
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "global_secondary_indexes" {
  description = "Global Secondary Indexes for the table"
  type = list(object({
    name            = string
    hash_key        = string
    range_key       = optional(string)
    projection_type = string
    read_capacity   = optional(number)
    write_capacity  = optional(number)
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "Local Secondary Indexes for the table"
  type = list(object({
    name            = string
    range_key       = string
    projection_type = string
  }))
  default = []
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for the table"
  type        = bool
  default     = false
}

variable "enable_encryption" {
  description = "Enable server-side encryption for the table"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (if enable_encryption is true)"
  type        = string
  default     = null
}

variable "ttl_attribute" {
  description = "Attribute name for TTL"
  type        = string
  default     = null
}

variable "stream_enabled" {
  description = "Enable DynamoDB streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES)"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
  validation {
    condition     = contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "Stream view type must be one of: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  }
}

variable "enable_dynamodb_alarms" {
  description = "Enable CloudWatch alarms for DynamoDB"
  type        = bool
  default     = false
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

# S3 Variables
variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "website"
}

variable "s3_bucket_purpose" {
  description = "Purpose description for the S3 bucket"
  type        = string
  default     = "Static website hosting"
}

variable "s3_force_destroy" {
  description = "Force destroy the S3 bucket even if it contains objects"
  type        = bool
  default     = false
}

variable "s3_versioning_enabled" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_website_config" {
  description = "Website configuration for the S3 bucket"
  type = object({
    index_document = string
    error_document = string
  })
  default = null
}

variable "s3_enable_public_read" {
  description = "Enable public read access for website hosting"
  type        = bool
  default     = false
}

variable "s3_block_public_acls" {
  description = "Block public ACLs for the S3 bucket"
  type        = bool
  default     = false
}

variable "s3_block_public_policy" {
  description = "Block public bucket policies for the S3 bucket"
  type        = bool
  default     = false
}

variable "s3_ignore_public_acls" {
  description = "Ignore public ACLs for the S3 bucket"
  type        = bool
  default     = false
}

variable "s3_restrict_public_buckets" {
  description = "Restrict public bucket policies for the S3 bucket"
  type        = bool
  default     = false
}

variable "s3_cors_rules" {
  description = "CORS rules for the S3 bucket"
  type        = any
  default     = []
}

variable "s3_lifecycle_rules" {
  description = "Lifecycle rules for the S3 bucket"
  type        = any
  default     = []
}

variable "s3_encryption_config" {
  description = "Server-side encryption configuration for the S3 bucket"
  type        = any
  default     = {}
}

variable "s3_logging_config" {
  description = "Logging configuration for the S3 bucket"
  type        = any
  default     = {}
}

variable "s3_static_files" {
  description = "Static files to upload to the S3 bucket"
  type = map(object({
    source       = string
    content_type = string
  }))
  default = {}
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
