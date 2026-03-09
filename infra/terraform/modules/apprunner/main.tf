# App Runner — serwis z ECR jako source
# W10-T02: deploy catalog-api do App Runner

locals {
  common_tags = merge(var.tags, {
    Project   = "OrderFlow-AWS-Lab"
    Env       = "dev"
    ManagedBy = "terraform"
    Module    = "apprunner"
  })
}

# --- IAM: Access Role (App Runner pull z ECR) ---
# Trust: build.apprunner.amazonaws.com
# Policy: AWSAppRunnerServicePolicyForECRAccess (managed)

resource "aws_iam_role" "ecr_access" {
  name = "${var.name_prefix}-${var.service_name}-apprunner-ecr-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-${var.service_name}-apprunner-ecr-access"
  })
}

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.ecr_access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# --- App Runner Service ---

resource "aws_apprunner_service" "this" {
  service_name = "${var.name_prefix}-${var.service_name}"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.ecr_access.arn
    }

    image_repository {
      image_identifier      = "${var.ecr_repository_url}:${var.image_tag}"
      image_repository_type = "ECR"

      image_configuration {
        port                         = tostring(var.port)
        runtime_environment_variables = var.runtime_environment_variables
      }
    }

    auto_deployments_enabled = var.auto_deployments_enabled
  }

  instance_configuration {
    cpu               = var.cpu
    memory            = var.memory
    instance_role_arn = var.instance_role_arn
  }

  health_check_configuration {
    protocol            = "HTTP"
    path                = var.health_check_path
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-${var.service_name}"
  })
}
