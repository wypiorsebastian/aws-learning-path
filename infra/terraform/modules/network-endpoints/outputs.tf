# network-endpoints — outputs dla envs/dev i modułów aplikacyjnych

output "s3_gateway_endpoint_id" {
  description = "ID Gateway Endpointu S3 (lub null, jeśli wyłączony)"
  value       = try(aws_vpc_endpoint.s3_gateway[0].id, null)
}

output "dynamodb_gateway_endpoint_id" {
  description = "ID Gateway Endpointu DynamoDB (lub null, jeśli wyłączony)"
  value       = try(aws_vpc_endpoint.dynamodb_gateway[0].id, null)
}

output "secretsmanager_interface_endpoint_id" {
  description = "ID Interface Endpointu Secrets Manager (lub null, jeśli wyłączony)"
  value       = try(aws_vpc_endpoint.secretsmanager_interface[0].id, null)
}

output "ssm_interface_endpoint_id" {
  description = "ID Interface Endpointu SSM Parameter Store (lub null, jeśli wyłączony)"
  value       = try(aws_vpc_endpoint.ssm_interface[0].id, null)
}

output "endpoints_security_group_id" {
  description = "ID Security Group dla interface endpointów (sg_endpoints)"
  value       = aws_security_group.sg_endpoints.id
}

output "vpc_flow_log_id" {
  description = "ID VPC Flow Log (lub null, jeśli Flow Logs wyłączone)"
  value       = try(aws_flow_log.vpc[0].id, null)
}

output "vpc_flow_logs_log_group_name" {
  description = "Nazwa log group w CloudWatch dla VPC Flow Logs"
  value       = local.flow_logs_log_group_name
}

