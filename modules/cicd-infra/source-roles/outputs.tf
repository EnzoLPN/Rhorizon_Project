output "github_actions_nonprod_role_arn" {
  value = aws_iam_role.github_actions_nonprod.arn
}
output "github_actions_prod_role_arn" {
  value = aws_iam_role.github_actions_prod.arn
}
