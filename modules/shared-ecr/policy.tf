# --- Politiques d'accès Cross-Account ---
resource "aws_ecr_repository_policy" "cross_account_policy" {
  for_each   = length(var.allowed_read_principals) > 0 ? aws_ecr_repository.repo : {}
  repository = each.value.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountPull"
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_read_principals
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}
