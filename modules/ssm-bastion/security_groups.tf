# SG du Bastion : Pas d'ingress (SSM gère les connexions), et egress complet
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-${var.environment}-sg-ssm-bastion"
  description = "Security Group for SSM Bastion (no ingress rules)"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic for SSM agent and updates"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-sg-ssm-bastion"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

# Règle autorisant le bastion à joindre la base de données RDS sur le port 5432
resource "aws_security_group_rule" "rds_ingress_from_bastion" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.rds_security_group_id
  source_security_group_id = aws_security_group.bastion.id
  description              = "Allow Ingress PostgreSQL from SSM Bastion"
}
