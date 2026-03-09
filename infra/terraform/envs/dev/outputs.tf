# Outputs dla envs/dev — W10-T02: ECR + App Runner

output "ecr_catalog_api_url" {
  description = "URL repozytorium ECR catalog-api (do docker tag + push)"
  value       = module.ecr_catalog_api.repository_url
}

output "apprunner_catalog_api_url" {
  description = "URL serwisu App Runner catalog-api (https://...)"
  value       = module.apprunner_catalog_api.service_url
}

output "apprunner_catalog_api_status" {
  description = "Status serwisu App Runner (np. RUNNING)"
  value       = module.apprunner_catalog_api.service_status
}
