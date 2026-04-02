# IAM answers one of the most important AWS questions:
# "Who is allowed to do what?"
#
# In this project:
# - the Lambda service must be allowed to "become" our role
# - the role must be allowed to write logs
# - the role must be allowed to read/write the S3 upload bucket

# This IAM role is attached to both Lambda functions.
# When the function starts, AWS Lambda uses this role to decide what
# the code is allowed to access.
resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-${var.environment}-lambda-exec"

  # `assume_role_policy` defines who is allowed to use this role.
  # Here we allow the Lambda service itself (`lambda.amazonaws.com`)
  # to assume the role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# This attaches an AWS-managed policy created by AWS.
# It gives the Lambda permission to send logs to CloudWatch.
# Without this, your function may run but you would not see logs.
resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# This is a custom policy written directly in Terraform.
# It gives the Lambda permission to:
# - list the bucket
# - read uploaded files
# - write files if needed
#
# Why both bucket ARN forms?
# - `aws_s3_bucket.uploads.arn` refers to the bucket itself
# - `"${aws_s3_bucket.uploads.arn}/*"` refers to objects inside the bucket
resource "aws_iam_role_policy" "lambda_s3_access" {
  name = "${var.project_name}-${var.environment}-lambda-s3"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.uploads.arn,
          "${aws_s3_bucket.uploads.arn}/*"
        ]
      }
    ]
  })
}
