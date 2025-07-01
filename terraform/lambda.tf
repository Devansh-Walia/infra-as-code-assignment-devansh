locals {
  lambda_function_name = "${var.project_name}-hello-world"
  lambda_zip_file      = "hello_world_lambda.zip"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../src/hello_world.py"
  output_path = "${path.module}/${local.lambda_zip_file}"
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 14

  tags = {
    Name = "${local.lambda_function_name}-logs"
  }
}

resource "aws_lambda_function" "hello_world" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = local.lambda_function_name
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "hello_world.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs,
  ]

  tags = {
    Name = local.lambda_function_name
  }
}
