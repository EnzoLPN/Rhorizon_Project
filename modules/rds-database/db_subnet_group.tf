# Groupe de sous-reseaux RDS
resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-${var.environment}-rds-subnet-group"
  description = "Groupe de sous-reseaux pour la base de donnees RDS ${var.environment}"
  subnet_ids  = var.subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-subnet-group"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}
