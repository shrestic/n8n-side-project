terraform {
  # This says which Terraform version and provider plugins this project expects.
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      # The AWS provider is the plugin Terraform uses to talk to AWS.
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Terraform will create resources in this AWS region.
  # The value comes from `var.aws_region` in variables.tf / terraform.tfvars.
  region = var.aws_region
}
