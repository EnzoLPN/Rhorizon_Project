output "iam_role_arn" {
  value       = aws_iam_role.role.arn
  description = "ARN du role IAM pour le controller"
}
