output "repository_url" {
  description = "URL repozytorium ECR (np. 123456789012.dkr.ecr.eu-central-1.amazonaws.com/catalog-api)"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "ARN repozytorium ECR"
  value       = aws_ecr_repository.this.arn
}

output "repository_name" {
  description = "Nazwa repozytorium"
  value       = aws_ecr_repository.this.name
}
