variable "vpc_id" {
  description = "ID VPC, w której tworzone są endpointy i Flow Logs"
  type        = string
}

variable "private_route_table_id" {
  description = "ID route table private z modułu network-core (dla Gateway Endpoints S3/DynamoDB)"
  type        = string
}

variable "private_subnet_ids" {
  description = "ID subnetów private (private-a, private-b) z network-core, używane przez Interface Endpoints"
  type        = list(string)
}

variable "sg_app_id" {
  description = "ID Security Group aplikacyjnej (sg_app / sg_ecs) — źródło ruchu do interface endpointów"
  type        = string
}

variable "enable_s3_gateway_endpoint" {
  description = "Czy tworzyć Gateway Endpoint dla S3"
  type        = bool
  default     = true
}

variable "enable_dynamodb_gateway_endpoint" {
  description = "Czy tworzyć Gateway Endpoint dla DynamoDB"
  type        = bool
  default     = true
}

variable "enable_secretsmanager_interface_endpoint" {
  description = "Czy tworzyć Interface Endpoint dla Secrets Manager"
  type        = bool
  default     = true
}

variable "enable_ssm_interface_endpoint" {
  description = "Czy tworzyć Interface Endpoint dla SSM Parameter Store"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Czy włączyć VPC Flow Logs dla VPC (destination: CloudWatch Logs)"
  type        = bool
  default     = true
}

variable "flow_logs_destination_type" {
  description = "Typ destination dla Flow Logs (obecnie wspierane: \"cloudwatch\")"
  type        = string
  default     = "cloudwatch"
}

variable "flow_logs_log_group_name" {
  description = "Nazwa log group dla Flow Logs w CloudWatch; jeśli puste, zostanie użyta nazwa oparta o name_prefix"
  type        = string
  default     = ""
}

variable "flow_logs_retention_in_days" {
  description = "Retencja logów Flow Logs w dniach (dev: krótka, np. 7–14)"
  type        = number
  default     = 7
}

variable "flow_logs_traffic_type" {
  description = "Typ ruchu logowanego przez Flow Logs (ACCEPT / REJECT / ALL)"
  type        = string
  default     = "ACCEPT"
}

variable "name_prefix" {
  description = "Prefix w nazwach zasobów (np. orderflow-dev)"
  type        = string
  default     = "orderflow-dev"
}

variable "tags" {
  description = "Tagi bazowe (Project, Env itp.); będą zmergowane z common_tags w module"
  type        = map(string)
  default     = {}
}

