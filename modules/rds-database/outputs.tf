output "db_instance_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "Endpoint de connexion a la base de donnees (format hote:port)"
}

output "db_instance_address" {
  value       = aws_db_instance.postgres.address
  description = "Adresse DNS interne de l'instance de base de donnees"
}

output "db_instance_port" {
  value       = aws_db_instance.postgres.port
  description = "Port d'ecoute de la base de donnees (5432)"
}

output "db_instance_name" {
  value       = aws_db_instance.postgres.db_name
  description = "Nom de la base de donnees creee"
}

output "db_instance_username" {
  value       = aws_db_instance.postgres.username
  description = "Nom d'utilisateur de l'administrateur de la base de donnees"
}

output "db_instance_arn" {
  value       = aws_db_instance.postgres.arn
  description = "ARN de la base de données"
}
