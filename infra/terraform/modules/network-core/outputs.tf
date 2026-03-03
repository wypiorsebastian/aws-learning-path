# network-core — outputs dla envs/dev i modułu network-endpoints (W05/W07)

output "vpc_id" {
  description = "ID VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR bloku VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "ID subnetów public (public-a, public-b) — dla ALB"
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "private_subnet_ids" {
  description = "ID subnetów private (private-a, private-b) — dla ECS, RDS, Lambda, Interface Endpoints"
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "public_subnet_id_a" {
  description = "ID subnetu public-a (eu-central-1a)"
  value       = aws_subnet.public_a.id
}

output "public_subnet_id_b" {
  description = "ID subnetu public-b (eu-central-1b)"
  value       = aws_subnet.public_b.id
}

output "private_subnet_id_a" {
  description = "ID subnetu private-a (RDS subnet group, Interface Endpoints)"
  value       = aws_subnet.private_a.id
}

output "private_subnet_id_b" {
  description = "ID subnetu private-b (RDS subnet group, Interface Endpoints)"
  value       = aws_subnet.private_b.id
}

output "public_route_table_id" {
  description = "ID route table public"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID route table private — W05 doda trasy Gateway Endpoint (S3, DynamoDB)"
  value       = aws_route_table.private.id
}

output "nat_gateway_id" {
  description = "ID NAT Gateway (null gdy enable_nat_gateway = false)"
  value       = var.enable_nat_gateway ? aws_nat_gateway.this[0].id : null
}

output "igw_id" {
  description = "ID Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "sg_alb_id" {
  description = "ID SG ALB — przypiąć do Load Balancera"
  value       = aws_security_group.sg_alb.id
}

output "sg_ecs_id" {
  description = "ID SG ECS/Lambda (sg_app) — współdzielony przez ECS Fargate i Lambda w VPC"
  value       = aws_security_group.sg_app.id
}

output "sg_rds_id" {
  description = "ID SG RDS — przypiąć do RDS PostgreSQL"
  value       = aws_security_group.sg_rds.id
}
