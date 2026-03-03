variable "vpc_cidr" {
  description = "CIDR bloku VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Lista Availability Zones (kolejność: public-a, public-b, private-a, private-b)"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR subnetów public (public-a, public-b)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR subnetów private (private-a, private-b)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "enable_nat_gateway" {
  description = "Czy tworzyć NAT Gateway (dev: true)"
  type        = bool
  default     = true
}

variable "single_nat" {
  description = "1 NAT (dev) vs NAT per AZ; na przyszłość"
  type        = bool
  default     = true
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

variable "app_port" {
  description = "Port aplikacji dla ALB → ECS/Lambda (używany w SG)"
  type        = number
  default     = 8080
}
