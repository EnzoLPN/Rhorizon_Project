output "role_arn" {
  value       = aws_iam_role.deploy_role.arn
  description = "ARN du role de deploiement cree"
}
