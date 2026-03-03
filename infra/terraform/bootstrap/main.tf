# Bootstrap Terraform backend — S3 (lock: use_lockfile w envs/dev)
# Uruchom: terraform init && terraform plan && terraform apply
# Ten config używa local state; tworzy bucket S3 dla głównego Terraform (envs/dev)

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.project}-${var.env}"
  common_tags = merge(var.tags, {
    Project   = var.project
    Env       = var.env
    ManagedBy = "terraform"
    Module    = "bootstrap"
  })
}

# --- S3 bucket dla Terraform state ---

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${local.name_prefix}-terraform-state-${data.aws_caller_identity.current.account_id}"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-terraform-state"
  })
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

