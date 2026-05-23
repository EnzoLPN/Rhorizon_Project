output "cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "Nom du cluster EKS"
}

output "cluster_id" {
  value       = aws_eks_cluster.main.id
  description = "Identifiant unique du cluster EKS"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "Endpoint d'API du cluster Kubernetes"
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.main.certificate_authority[0].data
  description = "Donnees de certificat necessaires pour s'authentifier aupres du cluster"
}

output "oidc_provider_url" {
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
  description = "URL de l'Identity Provider OIDC associe au cluster"
}

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.oidc.arn
  description = "ARN du fournisseur OIDC EKS (pour les configurations IRSA)"
}

output "cluster_security_group_id" {
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description = "ID du groupe de securite cree automatiquement par EKS pour le cluster"
}

