provider "aws" {
  region  = "eu-central-1"
  profile = "swpr-dev"
}

# --- S3 Bucket dla stanu Terraforma ---
resource "aws_s3_bucket" "terraform_state" {
  bucket = "swpr-terraform-state-storage-${random_id.id.hex}"
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# --- DynamoDB dla blokad (Locking) ---
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "swpr-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# --- OIDC: Zaufanie dla GitHub Actions ---
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions_role" {
  name = "GitHubActionsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity",
      Effect = "Allow",
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn },
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub": "repo:wypiorsebastian/aws-learning-path:*"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "github_admin" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "random_id" "id" {
  byte_length = 4
}

output "terraform_state_bucket_name" {
  value = aws_s3_bucket.terraform_state.id
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_role.arn
}