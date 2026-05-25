# --- IAM Roles for Service Accounts (IRSA) ---

resource "aws_iam_role" "irsa" {
  for_each = var.irsa_roles

  name = each.value.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub" = "system:serviceaccount:${each.value.namespace}:${each.value.service_account}"
          }
        }
      }
    ]
  })

  tags = {
    Name        = each.value.role_name
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

resource "aws_iam_policy" "irsa" {
  for_each = var.irsa_roles

  name   = "${each.value.role_name}-policy"
  policy = each.value.policy_json
}

resource "aws_iam_role_policy_attachment" "irsa" {
  for_each = var.irsa_roles

  role       = aws_iam_role.irsa[each.key].name
  policy_arn = aws_iam_policy.irsa[each.key].arn
}

output "irsa_role_arns" {
  value = { for k, v in aws_iam_role.irsa : k => v.arn }
  description = "Map des ARNs des rôles IRSA créés"
}
