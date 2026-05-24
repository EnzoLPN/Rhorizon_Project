# --- Recuperation dynamique du certificat SSL de GitHub ---
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# --- Fournisseur OIDC IAM pour GitHub ---
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]

  tags = {
    Name        = "github-oidc-provider"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}
