# network-endpoints — Gateway Endpoints, Interface Endpoints, Flow Logs (W05 design, W07-T01)

data "aws_region" "current" {}

locals {
  common_tags = merge(var.tags, {
    Project   = "OrderFlow-AWS-Lab"
    Env       = "dev"
    ManagedBy = "terraform"
    Module    = "network-endpoints"
  })

  flow_logs_log_group_name = var.flow_logs_log_group_name != "" ? var.flow_logs_log_group_name : "${var.name_prefix}-vpc-flow-logs"
}

# --- Gateway Endpoints (S3, DynamoDB) ---

resource "aws_vpc_endpoint" "s3_gateway" {
  count = var.enable_s3_gateway_endpoint ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [var.private_route_table_id]

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-s3-gateway-endpoint"
  })
}

resource "aws_vpc_endpoint" "dynamodb_gateway" {
  count = var.enable_dynamodb_gateway_endpoint ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [var.private_route_table_id]

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-dynamodb-gateway-endpoint"
  })
}

# --- Interface Endpoints (Secrets Manager, SSM) ---

resource "aws_vpc_endpoint" "secretsmanager_interface" {
  count = var.enable_secretsmanager_interface_endpoint ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.private_subnet_ids
  security_group_ids = [aws_security_group.sg_endpoints.id]

  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-secretsmanager-interface-endpoint"
  })
}

resource "aws_vpc_endpoint" "ssm_interface" {
  count = var.enable_ssm_interface_endpoint ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.private_subnet_ids
  security_group_ids = [aws_security_group.sg_endpoints.id]

  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-ssm-interface-endpoint"
  })
}

# --- VPC Flow Logs → CloudWatch Logs ---

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "cloudwatch" ? 1 : 0

  name              = local.flow_logs_log_group_name
  retention_in_days = var.flow_logs_retention_in_days

  tags = merge(local.common_tags, {
    Name = local.flow_logs_log_group_name
  })
}

resource "aws_iam_role" "vpc_flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "cloudwatch" ? 1 : 0

  name = "${var.name_prefix}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-vpc-flow-logs-role"
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "cloudwatch" ? 1 : 0

  name = "${var.name_prefix}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_flow_log" "vpc" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "cloudwatch" ? 1 : 0

  vpc_id       = var.vpc_id
  traffic_type = var.flow_logs_traffic_type

  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  iam_role_arn    = aws_iam_role.vpc_flow_logs[0].arn

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-vpc-flow-logs"
  })
}

