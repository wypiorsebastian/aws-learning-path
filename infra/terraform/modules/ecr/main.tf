# ECR — repozytorium dla kontenerów (catalog-api, orders-api, etc.)
# W10-T02: ECR dla App Runner; W12: standaryzacja build/push

locals {
  common_tags = merge(var.tags, {
    Project   = "OrderFlow-AWS-Lab"
    Env       = "dev"
    ManagedBy = "terraform"
    Module    = "ecr"
  })
}

resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-${var.repository_name}"
  })
}

resource "aws_ecr_lifecycle_policy" "this" {
  count = var.lifecycle_policy_json != "" ? 1 : 0

  repository = aws_ecr_repository.this.name

  policy = var.lifecycle_policy_json
}
