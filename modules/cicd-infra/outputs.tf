output "gitlab_role_arn" {
  description = "ARN du role IAM a faire endosser par le runner GitLab CI/CD"
  value       = aws_iam_role.gitlab_ci.arn
}

output "oidc_provider_arn" {
  description = "ARN du fournisseur d identite OIDC GitLab"
  value       = aws_iam_openid_connect_provider.gitlab.arn
}
