output "bucket_logs_arn" {
  value       = aws_s3_bucket.logs.arn
  description = "ARN du bucket S3 de logs centralises"
}

output "bucket_logs_id" {
  value       = aws_s3_bucket.logs.id
  description = "Nom (ID) du bucket S3 de logs centralises"
}

output "bucket_backups_arn" {
  value       = aws_s3_bucket.backups.arn
  description = "ARN du bucket S3 de backups centralises"
}

output "bucket_backups_id" {
  value       = aws_s3_bucket.backups.id
  description = "Nom (ID) du bucket S3 de backups centralises"
}

output "bucket_assets_arn" {
  value       = aws_s3_bucket.assets.arn
  description = "ARN du bucket S3 d'assets centralises"
}

output "bucket_assets_id" {
  value       = aws_s3_bucket.assets.id
  description = "Nom (ID) du bucket S3 d'assets centralises"
}

output "kms_logs_key_arn" {
  value       = aws_kms_key.logs.arn
  description = "ARN de la cle KMS de chiffrement des logs"
}

output "kms_backups_key_arn" {
  value       = aws_kms_key.backups.arn
  description = "ARN de la cle KMS de chiffrement des backups"
}

output "kms_assets_key_arn" {
  value       = aws_kms_key.assets.arn
  description = "ARN de la cle KMS de chiffrement des assets"
}
