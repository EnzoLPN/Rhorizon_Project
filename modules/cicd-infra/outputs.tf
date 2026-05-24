output "github_actions_nonprod_role_arn" {
  description = "ARN du role IAM Non-Prod a faire endosser par le runner"
  value       = aws_iam_role.github_actions_nonprod.arn
}

output "github_actions_prod_role_arn" {
  description = "ARN du role IAM Prod a faire endosser par le runner"
  value       = aws_iam_role.github_actions_prod.arn
}

output "github_oidc_provider_arn" {
  description = "ARN du fournisseur d identite OIDC GitHub"
  value       = aws_iam_openid_connect_provider.github.arn
}
