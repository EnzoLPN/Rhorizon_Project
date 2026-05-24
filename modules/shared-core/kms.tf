# --- Cles de Chiffrement KMS ---

# 1. Cle KMS pour les Logs
resource "aws_kms_key" "logs" {
  description             = "Cle de chiffrement pour les logs d'audit et CloudTrail centralises"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid    = "EnableIAMUserPermissions"
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          }
          Action   = "kms:*"
          Resource = "*"
        },
        {
          Sid    = "AllowCloudTrailUsage"
          Effect = "Allow"
          Principal = {
            Service = "cloudtrail.amazonaws.com"
          }
          Action = [
            "kms:GenerateDataKey*",
            "kms:Decrypt"
          ]
          Resource = "*"
        }
      ],
      local.has_cross_account ? [
        {
          Sid    = "AllowCrossAccountUsage"
          Effect = "Allow"
          Principal = {
            AWS = local.cross_account_principals
          }
          Action = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ]
          Resource = "*"
        }
      ] : []
    )
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-kms-logs"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

resource "aws_kms_alias" "logs" {
  name          = "alias/${var.project_name}-logs-key"
  target_key_id = aws_kms_key.logs.key_id
}

# 2. Cle KMS pour les Backups (RDS, etc.)
resource "aws_kms_key" "backups" {
  description             = "Cle de chiffrement pour les backups centralises"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid    = "EnableIAMUserPermissions"
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          }
          Action   = "kms:*"
          Resource = "*"
        }
      ],
      local.has_cross_account ? [
        {
          Sid    = "AllowCrossAccountUsageBackups"
          Effect = "Allow"
          Principal = {
            AWS = local.cross_account_principals
          }
          Action = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ]
          Resource = "*"
        }
      ] : []
    )
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-kms-backups"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

resource "aws_kms_alias" "backups" {
  name          = "alias/${var.project_name}-backups-key"
  target_key_id = aws_kms_key.backups.key_id
}

# 3. Cle KMS pour les Assets applicatifs
resource "aws_kms_key" "assets" {
  description             = "Cle de chiffrement pour les documents et assets applicatifs"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid    = "EnableIAMUserPermissions"
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          }
          Action   = "kms:*"
          Resource = "*"
        }
      ],
      local.has_cross_account ? [
        {
          Sid    = "AllowCrossAccountUsageAssets"
          Effect = "Allow"
          Principal = {
            AWS = local.cross_account_principals
          }
          Action = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ]
          Resource = "*"
        }
      ] : []
    )
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-kms-assets"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

resource "aws_kms_alias" "assets" {
  name          = "alias/${var.project_name}-assets-key"
  target_key_id = aws_kms_key.assets.key_id
}
