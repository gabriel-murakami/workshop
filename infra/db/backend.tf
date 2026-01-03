terraform {
  required_version = ">= 1.5.0"

  # Backend recomendado (exemplo): S3 + DynamoDB.
  # Configure via: terraform init -backend-config=...
  backend "s3" {}
}
