# Rôle IAM et Profil d'instance pour le Bastion SSM
resource "aws_iam_role" "bastion" {
  name = "${var.project_name}-${var.environment}-ssm-bastion-role"

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
    Project     = upper(var.project_name)
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project_name}-${var.environment}-ssm-bastion-profile"
  role = aws_iam_role.bastion.name
}
