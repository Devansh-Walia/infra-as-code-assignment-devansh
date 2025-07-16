# Infrastructure as Code Assignment - Milestone 3

## Overview

This project implements a complete serverless user registration and verification system using AWS Lambda, API Gateway, DynamoDB, and S3, deployed with Terraform and automated through GitHub Actions CI/CD pipeline. This is the final Milestone 3 of a three-part Infrastructure as Code assignment that demonstrates advanced Terraform features, modular architecture, remote state management, security scanning, and production-ready CI/CD automation.

## Architecture

The complete implementation includes:

### Infrastructure Components

- **AWS Lambda Functions**: Two functions for user registration and verification
- **API Gateway HTTP API**: Multi-route endpoint supporting registration and verification
- **DynamoDB Table**: User storage with PAY_PER_REQUEST billing
- **S3 Bucket**: Static website hosting for success/error pages
- **CloudWatch Logs**: Comprehensive logging for all Lambda functions
- **IAM Roles & Policies**: Function-specific permissions following least privilege

### DevOps & Automation

- **GitHub Actions CI/CD**: Complete automation pipeline with OIDC authentication
- **Remote State Management**: S3 + DynamoDB backend for Terraform state
- **Modular Architecture**: Reusable Terraform modules with comprehensive documentation
- **Security Scanning**: Checkov integration with SARIF output
- **Automated Testing**: Comprehensive test suites for all milestones
- **Code Quality**: Terraform formatting, linting, and validation

## Prerequisites

Before deploying this infrastructure, ensure you have:

- **AWS CLI** configured with appropriate credentials
- **Terraform** >= 1.12.2 installed (matches CI/CD version)
- **Python** 3.7+ for running automated tests
- **GitHub Repository** with Actions enabled
- Access to AWS account with permissions for Lambda, API Gateway, DynamoDB, S3, IAM, and CloudWatch

## Project Structure

```
infra-as-code-assignment/
├── .github/workflows/         # GitHub Actions CI/CD
│   └── deploy.yaml           # Complete deployment pipeline
├── terraform-state/          # Remote state infrastructure
│   ├── main.tf              # S3 + DynamoDB for state management
│   ├── github_oidc.tf       # GitHub Actions OIDC authentication
│   ├── variables.tf         # State infrastructure variables
│   ├── outputs.tf           # State bucket, table, and role outputs
│   └── README.md            # State deployment instructions
├── terraform/               # Main infrastructure
│   ├── main.tf              # Provider and module configuration
│   ├── backend.tf           # Remote state backend config
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # All infrastructure outputs
│   ├── data.tfvars          # Environment-specific values
│   ├── lambda.tf            # Lambda module usage
│   ├── api_gateway.tf       # API Gateway module usage
│   └── user_storage.tf      # Storage module usage
├── modules/                 # Reusable Terraform modules
│   ├── lambda-function/     # Lambda function module
│   │   ├── main.tf          # Lambda resources
│   │   ├── variables.tf     # Module inputs
│   │   ├── outputs.tf       # Module outputs
│   │   └── README.md        # Module documentation
│   ├── api-gateway/         # API Gateway module
│   │   ├── main.tf          # API Gateway resources
│   │   ├── variables.tf     # Module inputs
│   │   ├── outputs.tf       # Module outputs
│   │   └── README.md        # Module documentation
│   └── user-storage/        # Storage module
│       ├── main.tf          # DynamoDB and S3 resources
│       ├── variables.tf     # Module inputs
│       ├── outputs.tf       # Module outputs
│       └── README.md        # Module documentation
├── src/                     # Lambda function source code
│   ├── register_user.py     # User registration function
│   └── verify_user.py       # User verification function
├── html/                    # Static website files
│   ├── index.html           # Success page
│   └── error.html           # Error page
├── tests/                   # Automated test suites
│   ├── test_milestone1.py   # Milestone 1 tests
│   ├── test_milestone2.py   # Milestone 2 tests
│   ├── test_milestone3.py   # Milestone 3 CI/CD tests
│   └── requirements.txt     # Python test dependencies
└── README.md                # This file
```

## GitHub Actions CI/CD Pipeline

### Pipeline Overview

The GitHub Actions workflow provides a complete CI/CD pipeline with:

- **Code Quality**: Terraform formatting, linting (TFLint), and validation
- **Security Scanning**: Checkov security analysis with SARIF output
- **Infrastructure Management**: Plan, apply, and destroy operations
- **Automated Testing**: Comprehensive test suite execution
- **OIDC Authentication**: Secure AWS access without stored credentials

### Workflow Jobs

1. **terraform-checks**: Format validation, linting, initialization, and validation
2. **security-scan**: Checkov security scanning with artifact upload
3. **terraform-plan**: Infrastructure planning for pull requests
4. **terraform-apply**: Infrastructure deployment for main branch
5. **terraform-destroy**: Manual infrastructure destruction

### GitHub Repository Setup

#### Step 1: Environment Configuration

Navigate to your repository: `Settings → Environments → Create environment: AWS_REGION`

**Environment Variables:**

- `AWS_REGION`: `eu-central-1` (or your preferred region)
- `AWS_ROLE_ARN`: `arn:aws:iam::160071257600:role/deva-iac-assignment-github-actions-role`

#### Step 2: OIDC Authentication

The pipeline uses OpenID Connect (OIDC) for secure AWS authentication:

- **No stored credentials** in GitHub
- **Short-lived tokens** (auto-expire)
- **Repository-specific** access only
- **Least privilege** IAM permissions

### Workflow Triggers

- **Push to master**: Runs checks, security scan, and applies infrastructure
- **Pull Request**: Runs checks, security scan, and plans infrastructure
- **Manual Dispatch**: Choose plan, apply, or destroy operations

## Deployment Instructions

### Phase 1: Deploy Remote State Infrastructure

```bash
# Deploy the remote state infrastructure first
cd terraform-state
terraform init
terraform plan
terraform apply

# Note the outputs for GitHub configuration
terraform output github_actions_role_arn
terraform output terraform_state_bucket
```

### Phase 2: Configure GitHub Repository

1. **Create Environment**: Settings → Environments → New environment: `AWS_REGION`
2. **Add Variables**:
   - `AWS_REGION`: Your AWS region (e.g., `eu-central-1`)
   - `AWS_ROLE_ARN`: Output from terraform-state deployment

### Phase 3: Deploy via GitHub Actions

**Option 1: Automatic Deployment**

```bash
# Push to master branch triggers automatic deployment
git add .
git commit -m "Deploy infrastructure"
git push origin master
```

**Option 2: Manual Deployment**

1. Go to repository → Actions → Deploy Infrastructure
2. Click "Run workflow"
3. Select "apply" action
4. Click "Run workflow"

### Phase 4: Verify Deployment

Check the GitHub Actions run for:

- ✅ All jobs completed successfully
- ✅ Infrastructure deployed
- ✅ Tests passed
- ✅ Security scan completed

## Local Development

### Setup

```bash
# Clone repository
git clone <your-repo-url>
cd infra-as-code-assignment

# Install dependencies
python3 -m venv test-env
source test-env/bin/activate
pip install -r tests/requirements.txt
```

### Local Deployment

```bash
# Deploy main infrastructure locally
cd terraform
terraform init
terraform plan -var-file="data.tfvars"
terraform apply -var-file="data.tfvars"
```

### Local Testing

```bash
# Run all test suites
python tests/test_milestone1.py
python tests/test_milestone2.py
python tests/test_milestone3.py
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

## Testing

### Automated Test Suites

#### Milestone 1 Tests

```bash
python tests/test_milestone1.py
```

Tests basic Lambda + API Gateway functionality.

#### Milestone 2 Tests

```bash
python tests/test_milestone2.py
```

Tests complete user registration and verification system:

- Valid user registration
- Successful user verification (returns index.html)
- Failed user verification (returns error.html)
- Invalid registration/verification handling
- Test idempotency and independence

#### Milestone 3 Tests

```bash
python tests/test_milestone3.py
```

Tests GitHub Actions CI/CD pipeline:

- Workflow file validation
- Terraform version consistency
- Remote state backend configuration
- Security scanning configuration
- Modular architecture validation
- Infrastructure functionality
- Documentation completeness

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

## Modular Architecture

### Lambda Function Module

**Location**: `modules/lambda-function/`

**Features**:

- Configurable runtime and memory
- Environment variable support
- CloudWatch logging integration
- IAM role and policy management

**Usage**:

```hcl
module "lambda_functions" {
  source = "./modules/lambda-function"

  functions = {
    "register-user" = {
      filename = "register_user.py"
      handler  = "register_user.lambda_handler"
      environment_variables = {
        DYNAMODB_TABLE = module.user_storage.dynamodb_table_name
      }
    }
  }

  prefix       = var.prefix
  project_name = var.project_name
  environment  = var.environment
}
```

### API Gateway Module

**Location**: `modules/api-gateway/`

**Features**:

- HTTP API with multiple routes
- Lambda integration support
- CORS configuration
- Automatic deployment

**Usage**:

```hcl
module "api_gateway" {
  source = "./modules/api-gateway"

  routes = {
    "register" = {
      method      = "PUT"
      route_key   = "PUT /register"
      lambda_arn  = module.lambda_functions.lambda_arns["register-user"]
    }
  }

  prefix       = var.prefix
  project_name = var.project_name
  environment  = var.environment
}
```

### User Storage Module

**Location**: `modules/user-storage/`

**Features**:

- DynamoDB table with configurable billing
- S3 bucket with static website hosting
- Public access configuration
- File upload automation

**Usage**:

```hcl
module "user_storage" {
  source = "./modules/user-storage"

  enable_website_hosting = true
  static_files = {
    "index.html" = "../html/index.html"
    "error.html" = "../html/error.html"
  }

  prefix       = var.prefix
  project_name = var.project_name
  environment  = var.environment
}
```

## Security Features

### OIDC Authentication

- **GitHub Actions** authenticates with AWS using OpenID Connect
- **No stored credentials** in GitHub repository
- **Repository-specific** access control
- **Time-limited tokens** with automatic expiration

### Security Scanning

- **Checkov** integration for Terraform security analysis
- **SARIF output** for GitHub Security tab integration
- **Continuous monitoring** on every code change
- **Policy compliance** validation

### IAM Best Practices

- **Least privilege** principle for all roles
- **Function-specific** permissions
- **Resource-level** access control
- **Regular permission** auditing

### Infrastructure Security

- **Encrypted state** storage in S3
- **State locking** with DynamoDB
- **VPC isolation** capability (extendable)
- **API rate limiting** support

## Performance Optimization

### Lambda Functions

- **Optimized memory**: 128MB default (configurable)
- **Timeout configuration**: 30 seconds default
- **Environment variables**: Cached for performance
- **CloudWatch integration**: Minimal overhead logging

### DynamoDB

- **PAY_PER_REQUEST**: Automatic scaling
- **Single-table design**: Optimized for access patterns
- **Consistent reads**: When required
- **Global secondary indexes**: Available for complex queries

### API Gateway

- **HTTP API**: Lower latency than REST API
- **Regional deployment**: Reduced latency
- **Caching support**: Available for frequently accessed data
- **Throttling**: Configurable rate limiting

### S3 Static Website

- **Global edge locations**: CloudFront integration ready
- **Optimized content**: Compressed HTML files
- **Browser caching**: Configured headers
- **CDN ready**: Easy CloudFront integration

## Monitoring and Observability

### CloudWatch Integration

- **Lambda logs**: Automatic log group creation
- **API Gateway logs**: Request/response logging
- **Custom metrics**: Application-specific monitoring
- **Alarms**: Configurable thresholds

### GitHub Actions Monitoring

- **Workflow status**: Real-time pipeline monitoring
- **Artifact storage**: Build and test artifacts
- **Security reports**: Checkov SARIF integration
- **Deployment history**: Complete audit trail

## Configuration Management

### Environment Variables

**terraform/data.tfvars**:

```hcl
# Project configuration
prefix       = "deva"
aws_region   = "eu-central-1"
project_name = "iac-assignment"
environment  = "dev"
```

### GitHub Environment Variables

**AWS_REGION Environment**:

- `AWS_REGION`: Target AWS region
- `AWS_ROLE_ARN`: GitHub Actions IAM role ARN

### Terraform Variables

**terraform/variables.tf**: Comprehensive variable definitions with descriptions, types, and defaults.

## Troubleshooting

### GitHub Actions Issues

#### Authentication Failures

```
Error: Could not assume role with OIDC
```

**Solution**: Verify GitHub environment variables and IAM role trust policy.

#### Terraform State Lock

```
Error: Error acquiring the state lock
```

**Solution**: Check DynamoDB table accessibility and state lock timeout.

#### Test Failures

```
Error: API Gateway URL not available
```

**Solution**: Ensure infrastructure deployment completed successfully.

### Local Development Issues

#### Backend Configuration

```
Error: Backend configuration changed
```

**Solution**: Run `terraform init -migrate-state` to migrate to remote backend.

#### Module Not Found

```
Error: Module not found
```

**Solution**: Ensure all module directories exist and contain required files.

### Infrastructure Issues

#### Lambda Permissions

```
Error: User is not authorized to perform: lambda:InvokeFunction
```

**Solution**: Check IAM policies and Lambda permissions for API Gateway.

#### DynamoDB Access

```
Error: User is not authorized to perform: dynamodb:PutItem
```

**Solution**: Verify Lambda execution role has DynamoDB permissions.

## Cleanup Instructions

### Destroy via GitHub Actions

1. Go to repository → Actions → Deploy Infrastructure
2. Click "Run workflow"
3. Select "destroy" action
4. Click "Run workflow"

### Destroy Locally

```bash
# Destroy main infrastructure
cd terraform
terraform destroy -var-file="data.tfvars"

# Destroy remote state infrastructure (after all projects)
cd ../terraform-state
terraform destroy
```

### Manual Cleanup

#### Test Data Cleanup

```bash
# Clean up test users from DynamoDB
aws dynamodb scan \
  --table-name deva-iac-assignment-users \
  --filter-expression "begins_with(userId, :prefix)" \
  --expression-attribute-values '{":prefix":{"S":"test-user-"}}'
```

#### S3 Bucket Cleanup

```bash
# Empty S3 bucket before destruction
aws s3 rm s3://deva-iac-assignment-website --recursive
```

## Advanced Features

### Multi-Environment Support

- **Environment-specific** tfvars files
- **Workspace management** for multiple deployments
- **Environment isolation** with separate state files

### Scaling Considerations

- **Lambda concurrency**: Configurable limits
- **DynamoDB scaling**: Auto-scaling policies
- **API Gateway throttling**: Rate limiting configuration
- **CloudFront integration**: Global content delivery

### Security Enhancements

- **WAF integration**: Web Application Firewall
- **VPC deployment**: Network isolation
- **Secrets management**: AWS Secrets Manager integration
- **Compliance scanning**: Additional security tools

## Best Practices Implemented

### Infrastructure as Code

- **Version control**: All infrastructure in Git
- **Immutable deployments**: Replace rather than modify
- **Environment parity**: Consistent across environments
- **Documentation**: Comprehensive README and module docs

### CI/CD Pipeline

- **Automated testing**: Every code change tested
- **Security scanning**: Continuous security validation
- **Code quality**: Formatting and linting enforcement
- **Deployment automation**: Consistent deployment process

### Terraform Best Practices

- **Module structure**: Reusable, well-documented modules
- **State management**: Remote state with locking
- **Variable validation**: Input validation and defaults
- **Output organization**: Structured, useful outputs

## Support and Maintenance

### Getting Help

1. **Check CloudWatch logs** for Lambda execution details
2. **Review GitHub Actions** workflow runs for CI/CD issues
3. **Verify AWS credentials** and permissions
4. **Run automated tests** to validate functionality
5. **Check module documentation** for usage examples

### Regular Maintenance

- **Update Terraform version** in workflow and locally
- **Review security scan results** and address findings
- **Monitor AWS costs** and optimize resource usage
- **Update dependencies** in requirements.txt
- **Review and rotate** IAM credentials periodically

### Contributing

1. **Fork repository** and create feature branch
2. **Make changes** following existing patterns
3. **Run tests** locally before pushing
4. **Create pull request** with detailed description
5. **Address review feedback** and merge when approved

## Conclusion

This project demonstrates a complete Infrastructure as Code implementation with:

- ✅ **Serverless architecture** with AWS Lambda, API Gateway, DynamoDB, and S3
- ✅ **Modular Terraform design** with reusable, documented modules
- ✅ **GitHub Actions CI/CD** with OIDC authentication and comprehensive pipeline
- ✅ **Security scanning** with Checkov and SARIF integration
- ✅ **Automated testing** with comprehensive test suites
- ✅ **Remote state management** with S3 and DynamoDB
- ✅ **Production-ready practices** with monitoring, logging, and error handling

The implementation follows industry best practices for Infrastructure as Code, DevOps automation, and cloud security, providing a solid foundation for production workloads.
