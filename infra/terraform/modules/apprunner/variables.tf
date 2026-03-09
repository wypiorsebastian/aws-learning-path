variable "service_name" {
  description = "Nazwa serwisu (np. catalog-api)"
  type        = string
}

variable "ecr_repository_url" {
  description = "URL repozytorium ECR (output z modułu ecr)"
  type        = string
}

variable "image_tag" {
  description = "Tag obrazu w ECR (np. latest, commit-sha)"
  type        = string
  default     = "latest"
}

variable "port" {
  description = "Port aplikacji (domyślnie 8080)"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Ścieżka health check (np. /health)"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Interwał health check (sekundy)"
  type        = number
  default     = 10
}

variable "health_check_timeout" {
  description = "Timeout health check (sekundy)"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Progi sukcesu health check"
  type        = number
  default     = 1
}

variable "health_check_unhealthy_threshold" {
  description = "Progi porażki health check"
  type        = number
  default     = 5
}

variable "cpu" {
  description = "CPU dla instancji (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "512"
}

variable "memory" {
  description = "Pamięć (512, 1024, 2048, 3072, 4096, 6144, 8192, 10240, 12288) MB"
  type        = string
  default     = "1024"
}

variable "auto_deployments_enabled" {
  description = "Auto-deploy przy nowym pushu do obrazu"
  type        = bool
  default     = true
}

variable "instance_role_arn" {
  description = "Opcjonalnie: IAM role dla działającej aplikacji (CloudWatch, Secrets, etc.)"
  type        = string
  default     = null
}

variable "runtime_environment_variables" {
  description = "Zmienne środowiskowe dla aplikacji"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix w nazwach zasobów (np. orderflow-dev)"
  type        = string
  default     = "orderflow-dev"
}

variable "tags" {
  description = "Tagi bazowe"
  type        = map(string)
  default     = {}
}
