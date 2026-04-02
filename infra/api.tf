# API Gateway is the public entry point for HTTP requests.
# In this project, it exposes one endpoint:
# GET /presign
#
# The normal request flow is:
# client -> API Gateway -> presign Lambda

resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-${var.environment}-http-api"
  protocol_type = "HTTP"
  tags          = local.common_tags
}

# An integration tells API Gateway what backend should handle the request.
# Here, the backend is the `presign` Lambda.
resource "aws_apigatewayv2_integration" "presign" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.presign.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# This creates the actual route the client will call.
# `GET /presign` means:
# - HTTP method: GET
# - path: /presign
resource "aws_apigatewayv2_route" "presign" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /presign"
  target    = "integrations/${aws_apigatewayv2_integration.presign.id}"
}

# A stage is a deployed version of the API.
# Using the special `$default` stage is the simplest setup for beginners.
# `auto_deploy = true` means route/integration changes go live automatically.
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
  tags        = local.common_tags
}

# Just like S3, API Gateway also needs permission to invoke Lambda.
# Without this block, hitting the endpoint would fail with a permission error.
resource "aws_lambda_permission" "allow_http_api_presign" {
  statement_id  = "AllowHttpApiInvokePresign"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.presign.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
