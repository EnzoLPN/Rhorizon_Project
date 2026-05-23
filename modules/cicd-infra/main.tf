# --- Recuperation dynamique du certificat SSL de GitLab ---
data "tls_certificate" "gitlab" {
  url = "https://gitlab.com"
}

# --- Fournisseur OIDC IAM pour GitLab ---
resource "aws_iam_openid_connect_provider" "gitlab" {
  url             = "https://gitlab.com"
  client_id_list  = ["https://gitlab.com"]
  thumbprint_list = [data.tls_certificate.gitlab.certificates[0].sha1_fingerprint]

  tags = {
    Name        = "gitlab-oidc-provider"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# --- Rôle IAM pour les runners de GitLab CI/CD ---
resource "aws_iam_role" "gitlab_ci" {
  name = "${var.environment}-gitlab-ci-role"

  # Relation de confiance restreignant l'acces uniquement a notre depot GitLab precis (Securite ANSSI)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.gitlab.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "gitlab.com:sub" = "project_path:${var.gitlab_organization}/${var.gitlab_project}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-gitlab-ci-role"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# --- Attachement de la politique d'administration pour Terraform ---
# Terraform necessite de larges privilèges pour provisionner l'ensemble de l'infrastructure
resource "aws_iam_role_policy_attachment" "gitlab_admin" {
  role       = aws_iam_role.gitlab_ci.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
