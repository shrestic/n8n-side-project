# S3 is the storage layer in this project.
# Your app uploads CSV files into this bucket.
# After upload, S3 can notify the processing Lambda automatically.

resource "aws_s3_bucket" "uploads" {
  bucket = var.s3_bucket_name
  tags   = local.common_tags
}

# AWS services are strict about cross-service calls.
# Even though S3 and Lambda are both in AWS, S3 is still not allowed
# to invoke your Lambda unless you grant permission explicitly.
resource "aws_lambda_permission" "allow_s3_csv_processor" {
  statement_id  = "AllowS3InvokeCsvProcessor"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.uploads.arn
}

# This resource wires the bucket to the CSV processor Lambda.
# Translation in plain English:
# "Whenever a new object is created with a PUT event in this bucket,
# call the csv_processor Lambda."
resource "aws_s3_bucket_notification" "csv_upload_event" {
  bucket = aws_s3_bucket.uploads.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_processor.arn
    events              = ["s3:ObjectCreated:Put"]
  }

  # We wait until the invoke permission exists, otherwise AWS may reject
  # the notification setup.
  depends_on = [aws_lambda_permission.allow_s3_csv_processor]
}
