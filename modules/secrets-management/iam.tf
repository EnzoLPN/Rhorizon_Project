# --- Rôle IAM et Politique pour IRSA ---
resource "aws_iam_policy" "secrets_access" {
  name        = "${var.environment}-eks-secrets-policy"
  description = "Politique autorisant EKS a lire les secrets de l environnement ${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.environment}/${var.project_name}/*"
      }
    ]
  })
}

resource "aws_iam_role" "secrets_app_role" {
  name = "${var.environment}-eks-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:default:${var.project_name}-app-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_attach" {
  role       = aws_iam_role.secrets_app_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}
