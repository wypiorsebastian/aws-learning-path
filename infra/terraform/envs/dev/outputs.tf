# Outputs dla envs/dev — W10-T02: ECR + App Runner; W12-T02: ECR orders-api

output "ecr_catalog_api_url" {
  description = "URL repozytorium ECR catalog-api (do docker tag + push)"
  value       = module.ecr_catalog_api.repository_url
}

output "ecr_orders_api_url" {
  description = "URL repozytorium ECR orders-api (Fargate build/push)"
  value       = module.ecr_orders_api.repository_url
}

output "apprunner_catalog_api_url" {
  description = "URL serwisu App Runner catalog-api (https://...)"
  value       = module.apprunner_catalog_api.service_url
}

output "apprunner_catalog_api_status" {
  description = "Status serwisu App Runner (np. RUNNING)"
  value       = module.apprunner_catalog_api.service_status
}
