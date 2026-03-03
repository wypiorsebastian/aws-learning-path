terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Brak backend = local state (domyślny). Ten config tworzy S3+DynamoDB dla głównego Terraform.
}
