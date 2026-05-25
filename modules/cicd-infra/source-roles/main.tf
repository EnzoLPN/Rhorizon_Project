resource "aws_iam_role" "github_actions_nonprod" {
  name = "${var.environment}-github-actions-nonprod-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Federated = var.oidc_provider_arn }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = { StringLike = { "token.actions.githubusercontent.com:sub" = "repo:${var.github_organization}/${var.github_project}:*" } }
    }]
  })
}

resource "aws_iam_policy" "github_actions_nonprod" {
  name = "${var.environment}-github-actions-nonprod-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = "sts:AssumeRole", Resource = "arn:aws:iam::${var.nonprod_account_id}:role/nonprod-eks-deploy-role" },
      { Effect = "Allow", Action = "ecr:*", Resource = "*" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_nonprod" {
  role = aws_iam_role.github_actions_nonprod.name
  policy_arn = aws_iam_policy.github_actions_nonprod.arn
}

resource "aws_iam_role" "github_actions_prod" {
  name = "${var.environment}-github-actions-prod-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow", Principal = { Federated = var.oidc_provider_arn }, Action = "sts:AssumeRoleWithWebIdentity",
      Condition = { StringEquals = { "token.actions.githubusercontent.com:sub" = "repo:${var.github_organization}/${var.github_project}:ref:refs/heads/main" } }
    }]
  })
}

resource "aws_iam_policy" "github_actions_prod" {
  name = "${var.environment}-github-actions-prod-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = "sts:AssumeRole", Resource = "arn:aws:iam::${var.prod_account_id}:role/prod-eks-deploy-role" },
      { Effect = "Allow", Action = ["ecr:*", "s3:*", "kms:*", "route53:*", "acm:*"], Resource = "*" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_prod" {
  role = aws_iam_role.github_actions_prod.name
  policy_arn = aws_iam_policy.github_actions_prod.arn
}
