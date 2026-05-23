data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# SG du Bastion : Pas d'ingress (SSM gère les connexions en sortant), et egress complet pour joindre l'API SSM
resource "aws_security_group" "bastion" {
  name        = "${var.environment}-sg-ssm-bastion"
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
    Name        = "${var.environment}-sg-ssm-bastion"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# Rôle IAM et Profil d'instance pour le Bastion SSM
resource "aws_iam_role" "bastion" {
  name = "${var.environment}-ssm-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# Rattachement de la politique standard requise pour SSM Session Manager
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.environment}-ssm-bastion-profile"
  role = aws_iam_role.bastion.name
}

# Instance EC2 Bastion
resource "aws_instance" "bastion" {
  ami                  = data.aws_ami.al2023.id
  instance_type        = "t3.nano"
  subnet_id            = var.subnet_id
  iam_instance_profile = aws_iam_instance_profile.bastion.name

  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]

  associate_public_ip_address = false

  tags = {
    Name        = "${var.environment}-ssm-bastion"
    Environment = var.environment
    Project     = "RHZORION"
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
