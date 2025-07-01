# Infrastructure as Code Assignment - Milestone 1

## Overview

This project implements a serverless "Hello World" application using AWS Lambda and API Gateway, deployed with Terraform. This is Milestone 1 of a three-part Infrastructure as Code assignment that demonstrates basic Terraform usage, AWS serverless architecture, and automated testing.

## Architecture

The current implementation includes:

- **AWS Lambda Function**: A simple Python function that returns "Hello world"
- **API Gateway HTTP API**: Provides a public endpoint that triggers the Lambda function
- **CloudWatch Logs**: For Lambda function logging and debugging
- **IAM Roles & Policies**: Following least privilege principle for Lambda execution

## Prerequisites

Before deploying this infrastructure, ensure you have:

- **AWS CLI** configured with appropriate credentials
- **Terraform** >= 1.0 installed
- **Python** 3.7+ for running automated tests
- Access to AWS account with permissions to create Lambda, API Gateway, IAM, and CloudWatch resources

## Project Structure

```
infra-as-code-assignment/
├── terraform/                 # Terraform infrastructure code
│   ├── main.tf               # Provider configuration and data sources
│   ├── variables.tf          # Input variables
│   ├── outputs.tf            # Output values
│   ├── lambda.tf             # Lambda function and CloudWatch logs
│   ├── api_gateway.tf        # API Gateway configuration
│   └── iam.tf                # IAM roles and policies
├── src/                      # Lambda function source code
│   └── hello_world.py        # Simple "Hello world" Lambda function
├── tests/                    # Automated tests
│   ├── test_milestone1.py    # Test script for Milestone 1
│   └── requirements.txt      # Python test dependencies
└── README.md                 # This file
```

## Deployment Instructions

### 1. Clone and Navigate to Project

```bash
git clone <your-repo-url>
cd infra-as-code-assignment
```

### 2. Configure AWS Credentials

Ensure your AWS credentials are configured:

```bash
aws configure
# OR
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_DEFAULT_REGION=eu-central-1
```

### 3. Initialize Terraform

```bash
cd terraform
terraform init
```

### 4. Review and Deploy Infrastructure

```bash
# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
```

When prompted, type `yes` to confirm the deployment.

### 5. Get API Gateway URL

After successful deployment, get the API Gateway URL:

```bash
terraform output api_gateway_url
```

## Testing Instructions

### Manual Testing

Test the deployed API Gateway endpoint:

```bash
# Get the API Gateway URL
API_URL=$(cd terraform && terraform output -raw api_gateway_url)

# Test the endpoint
curl $API_URL/
```

Expected response:

```json
{
  "message": "Hello world"
}
```

### Automated Testing

#### Setup Test Environment

```bash
# Create Python virtual environment (recommended)
python3 -m venv test-env
source test-env/bin/activate  # On Windows: test-env\Scripts\activate

# Install test dependencies
pip install -r tests/requirements.txt
```

#### Run Tests

```bash
# Run the automated test suite
python tests/test_milestone1.py
```

The test script will:

1. Verify Lambda function exists with correct naming
2. Test API Gateway endpoint returns "Hello world" response
3. Provide detailed output and results

## Verification Checklist

After deployment, verify:

- [ ] `terraform output api_gateway_url` returns a valid URL
- [ ] GET request to `<api-gateway-url>/` returns "Hello world" message
- [ ] CloudWatch logs show Lambda execution (check AWS Console)
- [ ] Automated tests pass successfully

## Cleanup Instructions

### Destroy Infrastructure

```bash
cd terraform
terraform destroy
```

When prompted, type `yes` to confirm the destruction.

### Verify Cleanup

Check the AWS Console to ensure all resources have been deleted:

- Lambda functions
- API Gateway APIs
- IAM roles and policies
- CloudWatch log groups

## Configuration

### Customization

You can customize the deployment by modifying variables in `terraform/variables.tf`:

- `prefix`: Resource name prefix (default: "deva")
- `aws_region`: AWS region (default: "eu-central-1")
- `project_name`: Project name for resource naming (default: "iac-assignment")
- `environment`: Environment tag (default: "dev")

### Alternative Configuration

Create a `terraform.tfvars` file in the terraform directory:

```hcl
prefix       = "your-prefix"
aws_region   = "your-preferred-region"
project_name = "your-project-name"
```

## Troubleshooting

### Common Issues

1. **AWS Credentials**: Ensure AWS credentials are properly configured
2. **Permissions**: Verify your AWS user has necessary permissions for Lambda, API Gateway, IAM, and CloudWatch
3. **Region**: Ensure you're deploying to a region where all services are available
4. **Terraform State**: If deployment fails, check `terraform.tfstate` for partial resources

### Debug Lambda Function

Check CloudWatch logs:

1. Go to AWS Console → CloudWatch → Log groups
2. Find `/aws/lambda/<your-lambda-function-name>`
3. View recent log streams for execution details

### Test Failures

If automated tests fail:

1. Verify infrastructure is deployed: `terraform plan` should show no changes
2. Check API Gateway URL is accessible
3. Verify Lambda function is responding correctly
4. Check CloudWatch logs for Lambda errors

## Next Steps

This completes Milestone 1. Future milestones will add:

- **Milestone 2**: DynamoDB, S3, user registration/verification functionality
- **Milestone 3**: CI/CD with GitHub Actions, advanced Terraform features

## Support

For issues or questions:

1. Check CloudWatch logs for Lambda execution details
2. Verify AWS credentials and permissions
3. Review Terraform plan output for configuration issues
4. Ensure all prerequisites are met
