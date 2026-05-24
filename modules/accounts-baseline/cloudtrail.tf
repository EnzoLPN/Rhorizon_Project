# Cle KMS CloudTrail Organization
resource "aws_kms_key" "cloudtrail" {
  description             = "Cle KMS pour chiffrer les logs CloudTrail de l organisation"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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
    ]
  })
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/${var.project_name}-cloudtrail-key"
  target_key_id = aws_kms_key.cloudtrail.key_id
}

# Configuration CloudTrail global
resource "aws_cloudtrail" "org_trail" {
  name                          = "${var.project_name}-org-trail"
  s3_bucket_name                = "${var.project_name}-audit-logs"
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  is_organization_trail         = true
  is_multi_region_trail        = true
  include_global_service_events = true
  enable_log_file_validation    = true
}
