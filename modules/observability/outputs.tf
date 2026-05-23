output "fluent_bit_role_arn" {
  value       = aws_iam_role.fluent_bit.arn
  description = "ARN du role IAM attribue a Fluent Bit (IRSA)"
}
