# Lambda Function Module

This module creates AWS Lambda functions with associated IAM roles, policies, and CloudWatch log groups following best practices.

## Features

- **Multiple Lambda Functions**: Deploy multiple functions using `for_each`
- **IAM Security**: Function-specific IAM roles with least privilege policies
- **CloudWatch Integration**: Automatic log group creation with configurable retention
- **API Gateway Integration**: Automatic permissions for API Gateway invocation
- **Flexible Configuration**: Customizable runtime, timeout, memory, and environment variables

## Usage

```hcl
module "lambda_functions" {
  source = "./modules/lambda-function"

  prefix                    = "myapp"
  project_name             = "user-service"
  aws_region               = "eu-central-1"
  api_gateway_execution_arn = aws_apigatewayv2_api.main.execution_arn

  functions = {
    register-user = {
      source_file = "${path.module}/../src/register_user.py"
      handler     = "register_user.lambda_handler"
      description = "Register new users in DynamoDB"
      environment_vars = {
        DB_TABLE_NAME = aws_dynamodb_table.users.name
      }
      iam_policies = [
        {
          effect    = "Allow"
          actions   = ["dynamodb:PutItem"]
          resources = [aws_dynamodb_table.users.arn]
        }
      ]
    }
    verify-user = {
      source_file = "${path.module}/../src/verify_user.py"
      handler     = "verify_user.lambda_handler"
      description = "Verify users and return HTML from S3"
      environment_vars = {
        DB_TABLE_NAME = aws_dynamodb_table.users.name
        WEBSITE_S3    = aws_s3_bucket.website.bucket
      }
      iam_policies = [
        {
          effect    = "Allow"
          actions   = ["dynamodb:GetItem"]
          resources = [aws_dynamodb_table.users.arn]
        },
        {
          effect    = "Allow"
          actions   = ["s3:GetObject"]
          resources = ["${aws_s3_bucket.website.arn}/*"]
        }
      ]
    }
  }

  # Optional configurations
  runtime            = "python3.9"
  timeout            = 30
  memory_size        = 128
  log_retention_days = 14

  common_tags = {
    Environment = "dev"
    Project     = "user-service"
  }
}
```

## Inputs

| Name                      | Description                                      | Type          | Default       | Required |
| ------------------------- | ------------------------------------------------ | ------------- | ------------- | :------: |
| prefix                    | Prefix for resource names                        | `string`      | n/a           |   yes    |
| project_name              | Name of the project for resource naming          | `string`      | n/a           |   yes    |
| aws_region                | AWS region for resources                         | `string`      | n/a           |   yes    |
| functions                 | Map of Lambda functions to create                | `map(object)` | n/a           |   yes    |
| api_gateway_execution_arn | API Gateway execution ARN for Lambda permissions | `string`      | n/a           |   yes    |
| runtime                   | Lambda runtime                                   | `string`      | `"python3.9"` |    no    |
| timeout                   | Lambda function timeout in seconds               | `number`      | `30`          |    no    |
| memory_size               | Lambda function memory size in MB                | `number`      | `128`         |    no    |
| log_retention_days        | CloudWatch log retention in days                 | `number`      | `14`          |    no    |
| common_tags               | Common tags to apply to all resources            | `map(string)` | `{}`          |    no    |

## Outputs

| Name                 | Description                        |
| -------------------- | ---------------------------------- |
| functions            | Map of Lambda function resources   |
| function_names       | Map of Lambda function names       |
| function_arns        | Map of Lambda function ARNs        |
| function_invoke_arns | Map of Lambda function invoke ARNs |
| execution_roles      | Map of Lambda execution role ARNs  |
| log_groups           | Map of CloudWatch log group names  |

## Function Configuration

Each function in the `functions` map should have the following structure:

```hcl
{
  source_file      = string           # Path to the Python source file
  handler          = string           # Lambda handler (e.g., "filename.function_name")
  description      = string           # Function description
  environment_vars = map(string)      # Environment variables
  iam_policies = list(object({        # IAM policies for the function
    effect    = string                # "Allow" or "Deny"
    actions   = list(string)          # List of IAM actions
    resources = list(string)          # List of resource ARNs
  }))
}
```

## Security Features

- **Least Privilege**: Each function gets only the IAM permissions it needs
- **Separate Roles**: Each function has its own IAM execution role
- **CloudWatch Logging**: Automatic log group creation with proper permissions
- **Resource Isolation**: Functions are isolated from each other

## Best Practices

1. **Source Code Management**: Keep Lambda source code in a dedicated `src/` directory
2. **Environment Variables**: Use environment variables for configuration, not hardcoded values
3. **IAM Policies**: Define minimal required permissions for each function
4. **Logging**: Use CloudWatch logs for debugging and monitoring
5. **Tagging**: Apply consistent tags for resource management

## Examples

### Simple Function

```hcl
functions = {
  hello-world = {
    source_file = "${path.module}/../src/hello_world.py"
    handler     = "hello_world.lambda_handler"
    description = "Simple hello world function"
    environment_vars = {}
    iam_policies = []  # No additional permissions needed
  }
}
```

### Function with DynamoDB Access

```hcl
functions = {
  data-processor = {
    source_file = "${path.module}/../src/processor.py"
    handler     = "processor.lambda_handler"
    description = "Process data and store in DynamoDB"
    environment_vars = {
      TABLE_NAME = aws_dynamodb_table.data.name
    }
    iam_policies = [
      {
        effect    = "Allow"
        actions   = ["dynamodb:PutItem", "dynamodb:GetItem"]
        resources = [aws_dynamodb_table.data.arn]
      }
    ]
  }
}
```

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- Python source files must exist at the specified paths
- API Gateway must be created before using this module (for execution ARN)
