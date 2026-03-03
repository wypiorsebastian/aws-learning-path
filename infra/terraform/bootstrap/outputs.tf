output "s3_bucket_name" {
  description = "Nazwa bucketu S3 dla Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "region" {
  description = "Region AWS"
  value       = var.region
}
