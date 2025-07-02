# Infrastructure as Code Assignment - Milestone 2

## Overview

This project implements a complete serverless user registration and verification system using AWS Lambda, API Gateway, DynamoDB, and S3, deployed with Terraform. This is Milestone 2 of a three-part Infrastructure as Code assignment that demonstrates advanced Terraform features, remote state management, and comprehensive testing.

## Architecture

The current implementation includes:

- **Remote State Management**: S3 + DynamoDB backend for Terraform state
- **AWS Lambda Functions**: Two functions for user registration and verification
- **API Gateway HTTP API**: Multi-route endpoint supporting registration and verification
- **DynamoDB Table**: User storage with PAY_PER_REQUEST billing
- **S3 Bucket**: Static website hosting for success/error pages
- **CloudWatch Logs**: Comprehensive logging for all Lambda functions
- **IAM Roles & Policies**: Function-specific permissions following least privilege

## Prerequisites

Before deploying this infrastructure, ensure you have:

- **AWS CLI** configured with appropriate credentials
- **Terraform** >= 1.0 installed
- **Python** 3.7+ for running automated tests
- Access to AWS account with permissions for Lambda, API Gateway, DynamoDB, S3, IAM, and CloudWatch

## Project Structure

```
infra-as-code-assignment/
├── terraform-state/           # Remote state infrastructure
│   ├── main.tf               # S3 + DynamoDB for state management
│   ├── variables.tf          # State infrastructure variables
│   ├── outputs.tf            # State bucket and table outputs
│   └── README.md             # State deployment instructions
├── terraform/                # Main infrastructure
│   ├── main.tf               # Provider configuration
│   ├── backend.tf            # Remote state backend config
│   ├── variables.tf          # Input variables
│   ├── outputs.tf            # All infrastructure outputs
│   ├── lambda.tf             # Multi-Lambda with for_each
│   ├── api_gateway.tf        # Multi-route API Gateway
│   ├── dynamodb.tf           # User storage table
│   ├── s3.tf                 # Website hosting with public module
│   └── iam.tf                # Function-specific IAM policies
├── src/                      # Lambda function source code
│   ├── register_user.py      # User registration function
│   └── verify_user.py        # User verification function
├── html/                     # Static website files
│   ├── index.html            # Success page
│   └── error.html            # Error page
├── tests/                    # Automated test suites
│   ├── test_milestone1.py    # Milestone 1 tests
│   ├── test_milestone2.py    # Milestone 2 tests
│   └── requirements.txt      # Python test dependencies
└── README.md                 # This file
```

## Deployment Instructions

### Phase 1: Deploy Remote State Infrastructure

```bash
# Deploy the remote state infrastructure first
cd terraform-state
terraform init
terraform plan
terraform apply

# Note the outputs for backend configuration
terraform output
```

### Phase 2: Deploy Main Infrastructure

```bash
# Return to main directory and deploy application infrastructure
cd ../terraform
terraform init  # Will prompt to migrate state to remote backend
terraform plan
terraform apply
```

When prompted about state migration, type `yes` to copy local state to remote backend.

### Phase 3: Verify Deployment

```bash
# Get the API Gateway URL
terraform output api_gateway_url
```

## API Endpoints

The deployed infrastructure provides the following endpoints:

### User Registration

```bash
PUT /register?userId=<user-id>
```

**Example:**

```bash
curl -X PUT "https://your-api-gateway-url/register?userId=john123"
```

**Response:**

```json
{
  "message": "Registered User Successfully"
}
```

### User Verification

```bash
GET /?userId=<user-id>
```

**Example:**

```bash
curl "https://your-api-gateway-url/?userId=john123"
```

**Response:** HTML page (index.html for success, error.html for failure)

## Testing Instructions

### Setup Test Environment

**Step 1: Create Virtual Environment**

```bash
# Create Python virtual environment
python3 -m venv test-env

# Activate virtual environment
# On macOS/Linux:
source test-env/bin/activate

# On Windows:
# test-env\Scripts\activate
```

**Step 2: Install Dependencies**

```bash
# Install test dependencies (ensure virtual environment is activated)
pip install -r tests/requirements.txt
```

**Step 3: Verify Setup**

```bash
# Verify requests library is installed
python -c "import requests; print('Dependencies installed successfully!')"
```

### Run Automated Tests

#### Milestone 1 Tests

```bash
# Test basic Lambda + API Gateway functionality
python tests/test_milestone1.py
```

#### Milestone 2 Tests

```bash
# Test complete user registration and verification system
python tests/test_milestone2.py
```

The Milestone 2 test suite includes:

1. **Valid User Registration**: Tests PUT /register with valid userId
2. **Successful User Verification**: Tests GET / with registered user (returns index.html)
3. **Failed User Verification**: Tests GET / with non-existent user (returns error.html)
4. **Invalid Registration**: Tests PUT /register without userId parameter
5. **Invalid Verification**: Tests GET / without userId parameter
6. **Test Idempotency**: Verifies tests can run multiple times
7. **Test Independence**: Verifies tests don't depend on each other

### Manual Testing

#### Test User Registration

```bash
API_URL=$(cd terraform && terraform output -raw api_gateway_url)
curl -X PUT "$API_URL/register?userId=testuser123"
```

#### Test User Verification (Success)

```bash
curl "$API_URL/?userId=testuser123"
# Should return index.html with success message
```

#### Test User Verification (Failure)

```bash
curl "$API_URL/?userId=nonexistentuser"
# Should return error.html with failure message
```

## Infrastructure Features

### Remote State Management

- **S3 Backend**: Secure, versioned state storage
- **DynamoDB Locking**: Prevents concurrent modifications
- **Encryption**: State files encrypted at rest

### Lambda Functions

- **Multi-Function Deployment**: Uses `for_each` to avoid code duplication
- **Environment Variables**: Configured per function
- **CloudWatch Integration**: Comprehensive logging
- **Least Privilege IAM**: Function-specific permissions

### API Gateway

- **HTTP API**: Cost-effective RESTful interface
- **Multi-Route Support**: PUT /register and GET / endpoints
- **CORS Configuration**: Enabled for web applications
- **Auto-Deploy**: Automatic deployment on changes

### Data Storage

- **DynamoDB**: Serverless, pay-per-request user storage
- **S3 Website**: Static HTML hosting with public access
- **File Upload**: Automated HTML file deployment

## Verification Checklist

After deployment, verify:

- [ ] `terraform output api_gateway_url` returns a valid URL
- [ ] PUT request to `/register?userId=<id>` registers users successfully
- [ ] GET request to `/?userId=<registered-id>` returns index.html
- [ ] GET request to `/?userId=<unregistered-id>` returns error.html
- [ ] CloudWatch logs show Lambda execution (check AWS Console)
- [ ] All automated tests pass successfully
- [ ] S3 bucket contains index.html and error.html files
- [ ] DynamoDB table exists and can store user data

## Cleanup Instructions

### Destroy Main Infrastructure

```bash
cd terraform
terraform destroy
```

### Destroy Remote State Infrastructure

⚠️ **Warning**: Only destroy this after destroying all projects using this remote state.

```bash
cd terraform-state
terraform destroy
```

### Manual Cleanup

#### Test Data Cleanup

Tests create users with IDs like: `test-user-{timestamp}-{uuid}`

To clean up test data:

1. **AWS Console**: DynamoDB → Tables → deva-iac-assignment-users → Delete items with userId starting with "test-user-"
2. **AWS CLI**:

```bash
aws dynamodb scan \
  --table-name deva-iac-assignment-users \
  --filter-expression "begins_with(userId, :prefix)" \
  --expression-attribute-values '{":prefix":{"S":"test-user-"}}'
```

#### S3 Bucket Cleanup

If S3 bucket is not empty:

```bash
aws s3 rm s3://deva-iac-assignment-website --recursive
```

## Configuration

### Customization

Modify variables in `terraform/data.tfvars`:

```hcl
# Backend configuration
terraform_state_bucket = "your-state-bucket"
terraform_locks_table  = "your-locks-table"

# Project configuration
prefix       = "your-prefix"
aws_region   = "your-region"
project_name = "your-project-name"
environment  = "your-environment"
```

### Advanced Configuration

For production deployments, consider:

- **Custom Domain**: Add Route53 and ACM for custom API domain
- **WAF**: Add Web Application Firewall for API protection
- **Monitoring**: Add CloudWatch alarms and dashboards
- **Backup**: Enable DynamoDB point-in-time recovery

## Troubleshooting

### Common Issues

1. **State Lock Errors**: Check DynamoDB table exists and is accessible
2. **Lambda Permissions**: Verify IAM roles have correct policies attached
3. **API Gateway 403**: Check Lambda permissions allow API Gateway invocation
4. **S3 Access Denied**: Verify bucket policy allows public read access
5. **DynamoDB Access**: Check Lambda has correct DynamoDB permissions

### Debug Lambda Functions

Check CloudWatch logs:

1. AWS Console → CloudWatch → Log groups
2. Find `/aws/lambda/deva-iac-assignment-{function-name}`
3. View recent log streams for execution details

### Test Failures

If automated tests fail:

1. Verify infrastructure is deployed: `terraform plan` should show no changes
2. Check API Gateway URL is accessible
3. Verify Lambda functions are responding correctly
4. Check CloudWatch logs for Lambda errors
5. Ensure DynamoDB table and S3 bucket are accessible

### Backend Issues

If remote state issues occur:

1. Verify S3 bucket exists and is accessible
2. Check DynamoDB table for state locking
3. Ensure AWS credentials have appropriate permissions
4. Verify backend configuration in `terraform/backend.tf`

## Security Features

- **Least Privilege IAM**: Each Lambda has minimal required permissions
- **Encrypted State**: S3 backend uses encryption at rest
- **VPC Isolation**: Can be extended with VPC configuration
- **API Rate Limiting**: Can be added with API Gateway throttling
- **Input Validation**: Lambda functions validate input parameters

## Performance Considerations

- **DynamoDB**: PAY_PER_REQUEST billing scales automatically
- **Lambda**: 30-second timeout, 128MB memory (adjustable)
- **S3**: Static website hosting with global edge locations
- **API Gateway**: HTTP API for lower latency and cost

## Next Steps

This completes Milestone 2. Future milestones will add:

- **Milestone 3**: CI/CD with GitHub Actions, advanced Terraform modules, security scanning

## Support

For issues or questions:

1. Check CloudWatch logs for Lambda execution details
2. Verify AWS credentials and permissions
3. Review Terraform plan output for configuration issues
4. Ensure all prerequisites are met
5. Run automated tests to verify functionality
