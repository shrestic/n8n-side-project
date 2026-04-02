# Terraform automatically loads every `.tf` file in this folder.
# That means `main.tf`, `iam.tf`, `lambda.tf`, `s3.tf`, and `api.tf`
# are all part of one single infrastructure definition.
#
# I keep this file intentionally small so you can treat it like the
# "table of contents" for the project.

locals {
  # `locals` are reusable values that help avoid repeating the same text.
  # Think of them like helper variables that are computed inside Terraform.

  # These become the final Lambda names you will see in the AWS console.
  presign_function_name       = "${var.project_name}-${var.environment}-presign"
  csv_processor_function_name = "${var.project_name}-${var.environment}-csv-processor"

  # Both Lambda functions need the same environment variables, so we define
  # them once here and reuse them in `lambda.tf`.
  #
  # When Terraform creates the Lambda, these values will appear in the
  # Lambda configuration under Environment variables.
  lambda_environment = {
    S3_BUCKET            = var.s3_bucket_name
    N8N_WEBHOOK_BASE_URL = var.n8n_webhook_base_url
    N8N_WEBHOOK_KEY      = var.n8n_webhook_key
    RDS_HOST             = var.rds_host
    RDS_PORT             = var.rds_port
    RDS_DB               = var.rds_db
    RDS_USER             = var.rds_user
    RDS_PASSWORD         = var.rds_password
  }

  # Tags are labels that AWS stores on resources.
  # They make it easier to filter by project/environment in the console.
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

# Read the Terraform files in this order if you are learning:
# 1. variables.tf  -> values you can change
# 2. main.tf       -> shared names and shared environment variables
# 3. lambda.tf     -> the two Lambda functions
# 4. api.tf        -> public HTTP endpoint for GET /presign
# 5. s3.tf         -> upload bucket and S3 event trigger
# 6. iam.tf        -> permissions that allow Lambda to do its job
