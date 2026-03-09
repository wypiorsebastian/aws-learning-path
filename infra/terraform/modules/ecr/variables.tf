variable "repository_name" {
  description = "Nazwa repozytorium ECR (np. catalog-api, orders-api)"
  type        = string
}

variable "name_prefix" {
  description = "Prefix w nazwach zasobów (np. orderflow-dev)"
  type        = string
  default     = "orderflow-dev"
}

variable "image_tag_mutability" {
  description = "MUTABLE lub IMMUTABLE — czy można nadpisywać tag"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Skanowanie obrazów przy pushu (security)"
  type        = bool
  default     = true
}

variable "lifecycle_policy_json" {
  description = "JSON lifecycle policy — np. keep ostatnich N obrazów; pusty = brak"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tagi bazowe"
  type        = map(string)
  default     = {}
}
