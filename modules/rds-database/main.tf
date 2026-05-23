# Groupe de sous-reseaux RDS
resource "aws_db_subnet_group" "main" {
  name        = "${var.environment}-rds-subnet-group"
  description = "Groupe de sous-reseaux pour la base de donnees RDS ${var.environment}"
  subnet_ids  = var.subnet_ids

  tags = {
    Name        = "${var.environment}-rds-subnet-group"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# Instance de base de donnees RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier = "${var.environment}-postgres"
  engine     = "postgres"
  # Utilisation d'une version stable supportee de PostgreSQL
  engine_version = "16.6"
  instance_class = var.instance_class

  # Configuration de la base de donnees
  db_name  = var.db_name
  username = var.admin_username
  password = var.admin_password
  port     = 5432

  # Raccordement reseau et securite
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]

  # Configuration du stockage
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage # Active l'autoscaling si > allocated_storage
  storage_type          = "gp3"

  # Chiffrement
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.storage_encrypted && var.kms_key_arn != "" ? var.kms_key_arn : null

  # Haute Disponibilite et Backups
  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00" # Creneau de backup nocturne
  maintenance_window      = "Sun:04:30-Sun:05:30"

  # Cycle de vie et protection
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.environment}-postgres-final-snapshot-${uuid()}"

  # Desactivation de l'acces public (renforce la conformite SecOps)
  publicly_accessible = false

  # Optionnel : active le monitoring de base
  monitoring_interval = 0 # Desactive par defaut pour reduire les couts et logs inutiles en dev

  tags = {
    Name        = "${var.environment}-postgres"
    Environment = var.environment
    Project     = "RHZORION"
  }

  lifecycle {
    ignore_changes = [
      password, # Evite de modifier le mot de passe s'il est gere par ailleurs
      final_snapshot_identifier # Evite les recréations induites par l'usage du uuid()
    ]
  }
}
