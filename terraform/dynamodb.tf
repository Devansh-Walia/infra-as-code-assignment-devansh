resource "aws_dynamodb_table" "users" {
  name         = "${var.prefix}-${var.project_name}-users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

  tags = {
    Name        = "${var.prefix}-${var.project_name}-users"
    Purpose     = "User registration storage"
    Environment = var.environment
  }
}
