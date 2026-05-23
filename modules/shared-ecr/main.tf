# --- Depots ECR ---
resource "aws_ecr_repository" "repo" {
  for_each             = toset(var.repository_names)
  name                 = each.key
  image_tag_mutability = "IMMUTABLE" # Securite ANSSI : Interdiction d'ecraser des tags existants

  image_scanning_configuration {
    scan_on_push = true # Securite ANSSI : Scan de vulnerabilites automatique
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  tags = {
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# --- Politiques de Cycle de Vie ECR ---
resource "aws_ecr_lifecycle_policy" "policy" {
  for_each   = aws_ecr_repository.repo
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Supprimer les images non taguees apres 7 jours"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Conserver uniquement les 10 dernieres images pour eviter le surcout"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

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
