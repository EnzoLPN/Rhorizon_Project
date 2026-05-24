# --- Coffre de secret de test pour l'application ---
resource "aws_secretsmanager_secret" "app_secret" {
  name                    = "${var.environment}/${var.project_name}/app-secrets"
  description             = "Secrets de configuration de l application RHZORION (${var.environment})"
  recovery_window_in_days = 7
  kms_key_id              = var.kms_key_arn

  tags = {
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

resource "aws_secretsmanager_secret_version" "app_secret_val" {
  secret_id = aws_secretsmanager_secret.app_secret.id
  secret_string = jsonencode({
    database_host     = "rds-endpoint-placeholder"
    database_user     = "postgres"
    database_password = "password-placeholder"
    jwt_secret_key    = "CHANGEME-MUST-BE-SET-VIA-AWS-CONSOLE-OR-CLI"
  })
}
