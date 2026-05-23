output "secrets_role_arn" {
  description = "ARN du role IAM associe au Service Account Kubernetes pour l acces aux secrets"
  value       = aws_iam_role.secrets_app_role.arn
}

output "test_secret_arn" {
  description = "ARN du secret de test cree dans AWS Secrets Manager"
  value       = aws_secretsmanager_secret.app_secret.arn
}

output "test_secret_name" {
  description = "Nom du secret de test"
  value       = aws_secretsmanager_secret.app_secret.name
}
