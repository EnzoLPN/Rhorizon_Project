# --- Rôle IAM pour GitHub Actions - Non-Prod ---
resource "aws_iam_role" "github_actions_nonprod" {
  name = "${var.environment}-github-actions-nonprod-role"

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
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_organization}/${var.github_project}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-github-actions-nonprod-role"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

resource "aws_iam_policy" "github_actions_nonprod" {
  name        = "${var.environment}-github-actions-nonprod-policy"
  description = "Autorise le role CI/CD nonprod a assumer des roles dans le compte Non-Prod"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowAssumeRoleNonProd"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::${var.nonprod_account_id}:role/*"
      },
      {
        Sid      = "AllowECRReadWrite"
        Effect   = "Allow"
        Action   = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_nonprod" {
  role       = aws_iam_role.github_actions_nonprod.name
  policy_arn = aws_iam_policy.github_actions_nonprod.arn
}
