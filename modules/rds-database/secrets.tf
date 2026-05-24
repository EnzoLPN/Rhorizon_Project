# Génération d'un mot de passe aléatoire robuste
resource "random_password" "db_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?" # Caractères autorisés par RDS PostgreSQL
}

# Création du secret dans AWS Secrets Manager
resource "aws_secretsmanager_secret" "rds_password" {
  name        = "${var.project_name}/${var.environment}/rds/db-admin-password"
  description = "Mot de passe administrateur pour l'instance RDS ${var.environment}"
  kms_key_id  = var.kms_key_arn != "" ? var.kms_key_arn : null

  recovery_window_in_days = 7

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-password-secret"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

# Stockage de la valeur du mot de passe dans le secret
resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = random_password.db_password.result
}
