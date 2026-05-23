# --- Installation du Secrets Store CSI Driver (Helm) ---
resource "helm_release" "csi_driver" {
  name       = "secrets-store-csi-driver"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  namespace  = "kube-system"
  version    = "1.6.0"

  # Configuration du chart Helm
  values = [
    yamlencode({
      syncSecret = {
        enabled = true
      }
      enableSecretRotation = true
      rotationPollInterval = "2m"
    })
  ]
}

# --- Installation du Provider AWS (ASCP) ---
resource "helm_release" "aws_provider" {
  name       = "secrets-store-csi-driver-provider-aws"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  namespace  = "kube-system"
  version    = "0.3.11"

  depends_on = [helm_release.csi_driver]
}

# --- Rôle IAM et Politique pour IRSA (Accès Secrets Manager) ---
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
        # Limite l'acces aux secrets commencer par le nom de l'environnement (Securite ANSSI)
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.environment}/rhzorion/*"
      }
    ]
  })
}

# Rôle IAM avec relation de confiance OIDC
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
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:default:rhzorion-app-sa"
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

# --- Coffre de secret de test pour l'application ---
resource "aws_secretsmanager_secret" "app_secret" {
  name                    = "${var.environment}/rhzorion/app-secrets"
  description             = "Secrets de configuration de l application RHZORION (${var.environment})"
  recovery_window_in_days = 7 # Faible delai pour le developpement et la demo
  kms_key_id              = var.kms_key_arn

  tags = {
    Environment = var.environment
    Project     = "RHZORION"
  }
}

resource "aws_secretsmanager_secret_version" "app_secret_val" {
  secret_id = aws_secretsmanager_secret.app_secret.id
  secret_string = jsonencode({
    database_host     = "rds-endpoint-placeholder"
    database_user     = "postgres"
    database_password = "password-placeholder"
    jwt_secret_key    = "token-de-sec-random-12345"
  })
}
