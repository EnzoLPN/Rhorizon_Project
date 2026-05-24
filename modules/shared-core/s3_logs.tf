# --- Bucket S3 de Logs / CloudTrail ---

resource "aws_s3_bucket" "logs" {
  bucket              = "${var.project_name}-audit-logs"
  object_lock_enabled = var.enable_object_lock
  force_destroy       = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-audit-logs"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.logs.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

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

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid       = "EnforceSSLRequestsOnly"
          Effect    = "Deny"
          Principal = "*"
          Action    = "s3:*"
          Resource = [
            aws_s3_bucket.logs.arn,
            "${aws_s3_bucket.logs.arn}/*"
          ]
          Condition = {
            Bool = {
              "aws:SecureTransport" = "false"
            }
          }
        },
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
