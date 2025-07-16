# Backend configuration for remote state
# Note: Backend configuration cannot use variables directly
terraform {
  backend "s3" {
    bucket         = "deva-terraform-state-d3700965"
    key            = "dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "deva-terraform-locks"

    encrypt = true
  }
}
