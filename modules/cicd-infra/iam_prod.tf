# --- Rôle IAM pour GitHub Actions - Prod ---
resource "aws_iam_role" "github_actions_prod" {
  name = "${var.environment}-github-actions-prod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_organization}/${var.github_project}:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-github-actions-prod-role"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

resource "aws_iam_policy" "github_actions_prod" {
  name        = "${var.environment}-github-actions-prod-policy"
  description = "Autorise le role CI/CD prod a administrer shared-services et assumer des roles dans le compte Prod"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowAssumeRoleProd"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::${var.prod_account_id}:role/*"
      },
      {
        Sid      = "AllowSharedResourceManagement"
        Effect   = "Allow"
        Action   = [
          "ecr:*",
          "s3:*",
          "kms:*",
          "route53:*",
          "acm:*"
        ]
        Resource = "*"
      },
      {
        Sid      = "AllowIAMReadOnly"
        Effect   = "Allow"
        Action   = [
          "iam:Get*",
          "iam:List*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_prod" {
  role       = aws_iam_role.github_actions_prod.name
  policy_arn = aws_iam_policy.github_actions_prod.arn
}
