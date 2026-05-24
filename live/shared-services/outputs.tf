output "bucket_logs_arn" {
  value       = module.shared_core.bucket_logs_arn
  description = "ARN du bucket S3 de logs centralises"
}

output "bucket_logs_id" {
  value       = module.shared_core.bucket_logs_id
  description = "Nom (ID) du bucket S3 de logs centralises"
}

output "bucket_backups_arn" {
  value       = module.shared_core.bucket_backups_arn
  description = "ARN du bucket S3 de backups centralises"
}

output "bucket_backups_id" {
  value       = module.shared_core.bucket_backups_id
  description = "Nom (ID) du bucket S3 de backups centralises"
}

output "bucket_assets_arn" {
  value       = module.shared_core.bucket_assets_arn
  description = "ARN du bucket S3 d'assets centralises"
}

output "bucket_assets_id" {
  value       = module.shared_core.bucket_assets_id
  description = "Nom (ID) du bucket S3 d'assets centralises"
}

output "kms_logs_key_arn" {
  value       = module.shared_core.kms_logs_key_arn
  description = "ARN de la cle KMS de chiffrement des logs"
}

output "kms_backups_key_arn" {
  value       = module.shared_core.kms_backups_key_arn
  description = "ARN de la cle KMS de chiffrement des backups"
}

output "kms_assets_key_arn" {
  value       = module.shared_core.kms_assets_key_arn
  description = "ARN de la cle KMS de chiffrement des assets"
}

# --- Outputs Registre de Conteneurs Partage (shared-ecr) ---
output "ecr_repository_urls" {
  value       = module.shared_ecr.repository_urls
  description = "Urls de connexion pour chaque depot ECR central"
}

output "ecr_repository_arns" {
  value       = module.shared_ecr.repository_arns
  description = "ARNs des depots ECR centraux"
}

# --- Outputs CI/CD Infra ---
output "github_actions_nonprod_role_arn" {
  value       = module.cicd_infra.github_actions_nonprod_role_arn
  description = "ARN du role IAM Non-Prod a faire endosser par le runner"
}

output "github_actions_prod_role_arn" {
  value       = module.cicd_infra.github_actions_prod_role_arn
  description = "ARN du role IAM Prod a faire endosser par le runner"
}
