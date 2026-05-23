data "aws_caller_identity" "current" {}

locals {
  cross_account_principals = compact([
    var.nonprod_account_id != "" ? "arn:aws:iam::${var.nonprod_account_id}:root" : "",
    var.prod_account_id != "" ? "arn:aws:iam::${var.prod_account_id}:root" : ""
  ])
  has_cross_account = length(local.cross_account_principals) > 0
}

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
    Name        = "${var.environment}-kms-logs"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

resource "aws_kms_alias" "logs" {
  name          = "alias/rhorizon-logs-key"
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
    Name        = "${var.environment}-kms-backups"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

resource "aws_kms_alias" "backups" {
  name          = "alias/rhorizon-backups-key"
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
    Name        = "${var.environment}-kms-assets"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

resource "aws_kms_alias" "assets" {
  name          = "alias/rhorizon-assets-key"
  target_key_id = aws_kms_key.assets.key_id
}

# --- Buckets S3 Centralises ---

# 1. Bucket S3 de Logs / CloudTrail
resource "aws_s3_bucket" "logs" {
  bucket              = "${var.bucket_prefix}-audit-logs"
  object_lock_enabled = var.enable_object_lock

  tags = {
    Name        = "${var.environment}-audit-logs"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# 2. Bucket S3 de Backups
resource "aws_s3_bucket" "backups" {
  bucket = "${var.bucket_prefix}-central-backups"

  tags = {
    Name        = "${var.environment}-central-backups"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# 3. Bucket S3 d'Assets applicatifs (Documents stockes)
resource "aws_s3_bucket" "assets" {
  bucket = "${var.bucket_prefix}-app-assets"

  tags = {
    Name        = "${var.environment}-app-assets"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# --- Configurations de Securite S3 (Systematique) ---

# Blocage d'acces public
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "backups" {
  bucket                  = aws_s3_bucket.backups.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket                  = aws_s3_bucket.assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Chiffrement KMS par defaut
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.logs.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.backups.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.assets.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# --- Object Lock (Pour bucket Logs uniquement, pour immuabilite legale) ---
resource "aws_s3_bucket_object_lock_configuration" "logs" {
  count  = var.enable_object_lock ? 1 : 0
  bucket = aws_s3_bucket.logs.id

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = var.object_lock_retention_days
    }
  }
}

# --- Cycle de vie (Passage vers IA puis Glacier) ---

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "logs-lifecycle"
    status = "Enabled"

    filter {}

    transition {
      days          = var.transition_to_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.transition_to_glacier_days
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id     = "backups-lifecycle"
    status = "Enabled"

    filter {}

    transition {
      days          = var.transition_to_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.transition_to_glacier_days
      storage_class = "GLACIER"
    }
  }
}

# --- Politiques de Bucket (Cross-Account & Services AWS) ---

# Politique pour le bucket de logs (CloudTrail et comptes nonprod/prod)
resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid    = "AllowCloudTrailWrite"
          Effect = "Allow"
          Principal = {
            Service = "cloudtrail.amazonaws.com"
          }
          Action   = "s3:PutObject"
          Resource = "${aws_s3_bucket.logs.arn}/*"
          Condition = {
            StringEquals = {
              "s3:x-amz-acl" = "bucket-owner-full-control"
            }
          }
        },
        {
          Sid    = "AllowCloudTrailAcl"
          Effect = "Allow"
          Principal = {
            Service = "cloudtrail.amazonaws.com"
          }
          Action   = "s3:GetBucketAcl"
          Resource = aws_s3_bucket.logs.arn
        }
      ],
      local.has_cross_account ? [
        {
          Sid    = "AllowCrossAccountWriteLogs"
          Effect = "Allow"
          Principal = {
            AWS = local.cross_account_principals
          }
          Action = [
            "s3:PutObject",
            "s3:PutObjectAcl"
          ]
          Resource = "${aws_s3_bucket.logs.arn}/*"
          Condition = {
            StringEquals = {
              "s3:x-amz-acl" = "bucket-owner-full-control"
            }
          }
        }
      ] : []
    )
  })
}

# Politique pour le bucket de backups (Comptes nonprod/prod)
resource "aws_s3_bucket_policy" "backups" {
  count  = local.has_cross_account ? 1 : 0
  bucket = aws_s3_bucket.backups.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountAccessBackups"
        Effect = "Allow"
        Principal = {
          AWS = local.cross_account_principals
        }
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.backups.arn,
          "${aws_s3_bucket.backups.arn}/*"
        ]
      }
    ]
  })
}

# Politique pour le bucket d'assets applicatifs (Comptes nonprod/prod)
resource "aws_s3_bucket_policy" "assets" {
  count  = local.has_cross_account ? 1 : 0
  bucket = aws_s3_bucket.assets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountAccessAssets"
        Effect = "Allow"
        Principal = {
          AWS = local.cross_account_principals
        }
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.assets.arn,
          "${aws_s3_bucket.assets.arn}/*"
        ]
      }
    ]
  })
}
