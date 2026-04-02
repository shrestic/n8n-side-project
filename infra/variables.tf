variable "aws_region" {
  description = "AWS region where Terraform will create resources."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in tags and resource names."
  type        = string
  default     = "loan-eligibility-engine"
}

variable "environment" {
  description = "Deployment environment such as dev, staging, or prod."
  type        = string
  default     = "dev"
}

variable "s3_bucket_name" {
  description = "Name of the upload bucket. This should be globally unique in AWS."
  type        = string
}

variable "presign_zip_path" {
  description = "Path to the zip file for the presign Lambda function."
  type        = string
}

variable "csv_processor_zip_path" {
  description = "Path to the zip file for the CSV processor Lambda function."
  type        = string
}

variable "presign_handler" {
  description = "Python handler for the presign Lambda."
  type        = string
  default     = "lambdas.presign_url_generator.handler.handler"
}

variable "csv_processor_handler" {
  description = "Python handler for the CSV processor Lambda."
  type        = string
  default     = "lambdas.csv_ingest.handler.handler"
}

variable "lambda_runtime" {
  description = "Runtime shared by both Lambda functions."
  type        = string
  default     = "python3.11"
}

variable "presign_timeout" {
  description = "Timeout in seconds for the presign Lambda."
  type        = number
  default     = 10
}

variable "csv_processor_timeout" {
  description = "Timeout in seconds for the CSV processor Lambda."
  type        = number
  default     = 120
}

variable "lambda_memory_size" {
  description = "Memory size in MB for both Lambda functions."
  type        = number
  default     = 512
}

variable "n8n_webhook_base_url" {
  description = "Base URL for the n8n webhook endpoint."
  type        = string
}

variable "n8n_webhook_key" {
  description = "Secret key used to authenticate webhook calls to n8n."
  type        = string
  sensitive   = true
}

variable "rds_host" {
  description = "RDS hostname used by the Lambda functions."
  type        = string
}

variable "rds_port" {
  description = "RDS port used by the Lambda functions."
  type        = string
}

variable "rds_db" {
  description = "Database name used by the Lambda functions."
  type        = string
}

variable "rds_user" {
  description = "Database username used by the Lambda functions."
  type        = string
  sensitive   = true
}

variable "rds_password" {
  description = "Database password used by the Lambda functions."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Extra AWS tags to apply to created resources."
  type        = map(string)
  default     = {}
}
