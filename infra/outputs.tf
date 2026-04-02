output "uploads_bucket_name" {
  description = "Name of the S3 bucket that receives uploaded files."
  value       = aws_s3_bucket.uploads.bucket
}

output "presign_lambda_name" {
  description = "Name of the Lambda behind GET /presign."
  value       = aws_lambda_function.presign.function_name
}

output "csv_processor_lambda_name" {
  description = "Name of the Lambda triggered by S3 uploads."
  value       = aws_lambda_function.csv_processor.function_name
}

output "http_api_endpoint" {
  description = "Base URL for the HTTP API. Your route will be GET /presign."
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}
