# GitHub OIDC Provider and IAM Role for GitHub Actions
# This allows GitHub Actions to assume AWS roles without storing credentials

# Use existing OIDC Identity Provider for GitHub Actions
data "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "${var.prefix}-${var.project_name}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:Devansh-Walia/infra-as-code-assignment-devansh:*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.prefix}-${var.project_name}-github-actions-role"
    Purpose     = "GitHub Actions execution role"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# IAM Policy for GitHub Actions - Terraform operations
resource "aws_iam_policy" "github_actions_terraform" {
  name        = "${var.prefix}-${var.project_name}-github-actions-terraform"
  description = "Policy for GitHub Actions to manage Terraform infrastructure"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 permissions for Terraform state
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
      },
      # DynamoDB permissions for state locking
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.terraform_locks.arn
      },
      # Lambda permissions
      {
        Effect = "Allow"
        Action = [
          "lambda:*"
        ]
        Resource = "*"
      },
      # API Gateway permissions
      {
        Effect = "Allow"
        Action = [
          "apigateway:*"
        ]
        Resource = "*"
      },
      # DynamoDB permissions for application
      {
        Effect = "Allow"
        Action = [
          "dynamodb:*"
        ]
        Resource = "*"
      },
      # S3 permissions for application
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "*"
      },
      # IAM permissions (limited)
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListPolicyVersions",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:UpdateRole",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:PassRole",
          "iam:TagRole",
          "iam:UntagRole"
        ]
        Resource = "*"
      },
      # CloudWatch Logs permissions
      {
        Effect = "Allow"
        Action = [
          "logs:*"
        ]
        Resource = "*"
      },
      # EC2 permissions for VPC info
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeRegions"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.prefix}-${var.project_name}-github-actions-terraform"
    Purpose     = "Terraform operations for GitHub Actions"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "github_actions_terraform" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_terraform.arn
}
