# --- Groupes de Securite de base (Tiers Applicatif) ---

# 1. Security Group pour l'ALB Public (Load Balancer)
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-sg-alb"
  description = "SG for Public ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-sg-alb"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

# 2. Security Group pour EKS (Nodes & Pods)
resource "aws_security_group" "app" {
  name        = "${var.project_name}-${var.environment}-sg-app"
  description = "SG for EKS Nodes and Pods"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow Ingress HTTP/HTTPS from ALB"
    from_port       = 8080
    to_port         = 8443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "Allow CoreDNS TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Allow CoreDNS UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    self        = true
  }

  egress {
    description = "Allow HTTPS Outbound (AWS API, endpoints)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow DNS Outbound TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow DNS Outbound UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-sg-app"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

# Rapprochement ALB -> EKS sans dependance circulaire
resource "aws_security_group_rule" "alb_egress_to_app" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.app.id
  description              = "Allow outbound to app tier"
}

# 3. Security Group pour RDS PostgreSQL
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-sg-rds"
  description = "SG for RDS PostgreSQL"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow outbound inside VPC only"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-sg-rds"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

resource "aws_security_group_rule" "rds_ingress_from_eks" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.app.id
  description              = "Allow Ingress PostgreSQL from EKS App only"
}
