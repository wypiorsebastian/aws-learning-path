variable "project" {
  description = "Nazwa projektu (np. orderflow)"
  type        = string
  default     = "orderflow"
}

variable "env" {
  description = "Środowisko (np. dev)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Region AWS"
  type        = string
  default     = "eu-central-1"
}

variable "tags" {
  description = "Dodatkowe tagi zasobów"
  type        = map(string)
  default     = {}
}
