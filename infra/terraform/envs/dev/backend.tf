# Backend S3 — bucket, region i key z pliku backend.dev.hcl (terraform init -backend-config=backend.dev.hcl)
# Utwórz backend.dev.hcl z bucket, region i key; nie commituj backend.dev.hcl (są w .gitignore)

terraform {
  backend "s3" {
    use_lockfile = true
  }
}
