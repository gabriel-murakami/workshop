resource "aws_ecr_repository" "app" {
  name = var.ecr_repository

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}
