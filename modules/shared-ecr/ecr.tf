# --- Depots ECR ---
resource "aws_ecr_repository" "repo" {
  for_each             = toset(var.repository_names)
  name                 = each.key
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  tags = {
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}
