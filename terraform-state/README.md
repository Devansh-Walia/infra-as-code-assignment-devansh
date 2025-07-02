# Terraform Remote State Infrastructure

This directory contains the infrastructure for Terraform remote state management using S3 and DynamoDB.

## Overview

This setup creates:

- **S3 Bucket**: For storing Terraform state files with versioning and encryption
- **DynamoDB Table**: For state locking to prevent concurrent modifications
- **Security**: Public access blocked, encryption enabled

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- Permissions to create S3 buckets and DynamoDB tables

## Deployment Instructions

### 1. Initialize Terraform

```bash
cd terraform-state
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

### 3. Deploy the Infrastructure

```bash
terraform apply
```

When prompted, type `yes` to confirm the deployment.

### 4. Note the Outputs

After deployment, note the outputs for configuring the main project:

```bash
terraform output
```

You'll need:

- `terraform_state_bucket`: S3 bucket name
- `terraform_locks_table`: DynamoDB table name
- `aws_region`: AWS region

## Usage

After deploying this infrastructure, update your main Terraform project's backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket         = "<terraform_state_bucket_output>"
    key            = "terraform.tfstate"
    region         = "<aws_region_output>"
    dynamodb_table = "<terraform_locks_table_output>"
    encrypt        = true
  }
}
```

## Cleanup

⚠️ **Warning**: Only destroy this infrastructure after destroying all projects that use this remote state.

```bash
terraform destroy
```

## Security Features

- **Encryption**: S3 bucket uses AES256 encryption
- **Versioning**: Enabled for state file history
- **Public Access**: Completely blocked
- **State Locking**: DynamoDB prevents concurrent modifications

## Troubleshooting

### Bucket Name Conflicts

If you get a bucket name conflict, the random suffix should prevent this. If it still occurs, run `terraform apply` again to generate a new random suffix.

### Permissions Issues

Ensure your AWS credentials have permissions for:

- S3: CreateBucket, PutBucketVersioning, PutBucketEncryption, PutBucketPublicAccessBlock
- DynamoDB: CreateTable
- IAM: Basic permissions for resource tagging
