resource "aws_iam_role" "deploy_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.trusted_role_arn
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = var.role_name
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

resource "aws_iam_role_policy_attachment" "deploy_admin" {
  role       = aws_iam_role.deploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
