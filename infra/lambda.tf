# This file creates the two Lambda functions from your original Serverless setup.
#
# Terraform does not build Python code for you.
# It only uploads zip files that already exist on disk.
# So before `terraform apply`, make sure these files exist:
# - `presign_zip_path`
# - `csv_processor_zip_path`

# CloudWatch log groups store the logs printed by your Lambda code.
# We create them ourselves so we can control settings like log retention.
# If we did not create them here, AWS would create them automatically on first run.
resource "aws_cloudwatch_log_group" "presign" {
  name              = "/aws/lambda/${local.presign_function_name}"
  retention_in_days = 14
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "csv_processor" {
  name              = "/aws/lambda/${local.csv_processor_function_name}"
  retention_in_days = 14
  tags              = local.common_tags
}

# Lambda 1: this is the function behind GET /presign.
# Its job is usually to generate a presigned S3 upload URL for the client.
resource "aws_lambda_function" "presign" {
  function_name    = local.presign_function_name
  role             = aws_iam_role.lambda_exec.arn
  filename         = var.presign_zip_path

  # `source_code_hash` helps Terraform detect when the zip file changed.
  # If you rebuild the zip, this hash changes, and Terraform knows to upload
  # the new version to Lambda.
  source_code_hash = filebase64sha256(var.presign_zip_path)
  handler          = var.presign_handler
  runtime          = var.lambda_runtime
  timeout          = var.presign_timeout
  memory_size      = var.lambda_memory_size

  # These become environment variables inside the running Lambda process.
  environment {
    variables = local.lambda_environment
  }

  # `depends_on` makes the order explicit.
  # Terraform is often smart enough to infer dependencies automatically,
  # but being explicit here is easier for beginners to follow:
  # 1. role + permissions exist
  # 2. log group exists
  # 3. then create Lambda
  depends_on = [
    aws_iam_role_policy_attachment.basic_execution,
    aws_iam_role_policy.lambda_s3_access,
    aws_cloudwatch_log_group.presign
  ]

  tags = local.common_tags
}

# Lambda 2: this function is triggered by S3 after a CSV upload.
# It is the worker/background processor in this architecture.
resource "aws_lambda_function" "csv_processor" {
  function_name    = local.csv_processor_function_name
  role             = aws_iam_role.lambda_exec.arn
  filename         = var.csv_processor_zip_path
  source_code_hash = filebase64sha256(var.csv_processor_zip_path)
  handler          = var.csv_processor_handler
  runtime          = var.lambda_runtime
  timeout          = var.csv_processor_timeout
  memory_size      = var.lambda_memory_size

  environment {
    variables = local.lambda_environment
  }

  # Same idea as above: create permissions/logging first, then the Lambda.
  depends_on = [
    aws_iam_role_policy_attachment.basic_execution,
    aws_iam_role_policy.lambda_s3_access,
    aws_cloudwatch_log_group.csv_processor
  ]

  tags = local.common_tags
}
