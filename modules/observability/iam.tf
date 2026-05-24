# --- Role IAM (IRSA) pour Fluent Bit ---
resource "aws_iam_role" "fluent_bit" {
  name = "${var.environment}-eks-fluent-bit-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:logging:fluent-bit"
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

resource "aws_iam_policy" "fluent_bit" {
  name        = "${var.environment}-eks-fluent-bit-policy"
  description = "Politique autorisant Fluent Bit a ecrire ses logs dans CloudWatch et S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/eks/${var.project_name}/${var.environment}/*"
      },
      {
        Effect = "Allow"
        Action = ["s3:PutObject"]
        Resource = "arn:aws:s3:::${var.logs_bucket_name}/eks/${var.environment}/*"
      },
      {
        Effect = "Allow"
        Action = ["s3:GetBucketLocation", "s3:ListBucket"]
        Resource = "arn:aws:s3:::${var.logs_bucket_name}"
      },
      {
        Effect = "Allow"
        Action = ["kms:GenerateDataKey", "kms:Decrypt", "kms:Encrypt"]
        Resource = var.kms_logs_key_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fluent_bit" {
  role       = aws_iam_role.fluent_bit.name
  policy_arn = aws_iam_policy.fluent_bit.arn
}
