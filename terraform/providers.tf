terraform {
  # Require at least Terraform 1.8.0
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.8.0" # AWS provider version
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0" # Random provider version (for unique names, etc.)
    }
  }
}

# AWS provider configuration
provider "aws" {
  region = "us-east-1" # Lambda@Edge must be created in us-east-1 (N. Virginia)
}
