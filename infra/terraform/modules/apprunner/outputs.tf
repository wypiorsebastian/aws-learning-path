output "service_url" {
  description = "URL serwisu App Runner (https://...)"
  value       = aws_apprunner_service.this.service_url
}

output "service_arn" {
  description = "ARN serwisu App Runner"
  value       = aws_apprunner_service.this.arn
}

output "service_id" {
  description = "ID serwisu App Runner"
  value       = aws_apprunner_service.this.service_id
}

output "service_status" {
  description = "Status serwisu (np. RUNNING)"
  value       = aws_apprunner_service.this.status
}
