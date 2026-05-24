# Instance de base de donnees RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-${var.environment}-postgres"
  engine     = "postgres"
  engine_version = "16.6"
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.admin_username
  password = random_password.db_password.result
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.storage_encrypted && var.kms_key_arn != "" ? var.kms_key_arn : null

  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "Sun:04:30-Sun:05:30"

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-${var.environment}-postgres-final-snapshot"

  publicly_accessible = false
  monitoring_interval = 0

  iam_database_authentication_enabled = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres"
    Environment = var.environment
    Project     = upper(var.project_name)
  }

  lifecycle {
    ignore_changes = [
      password,
      final_snapshot_identifier
    ]
  }
}
