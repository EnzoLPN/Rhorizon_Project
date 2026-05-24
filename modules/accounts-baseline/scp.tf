# --- Service Control Policies (SCPs) ---

resource "aws_organizations_policy" "eu_only" {
  name        = "eu-only-regions"
  description = "Interdit le deploiement de ressources en dehors des regions europeennes autorisees"
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyAllOutsideEU"
        Effect   = "Deny"
        NotAction = [
          "iam:*", "organizations:*", "route53:*", "budgets:*", "support:*", "sso:*",
          "identitystore:*", "cloudfront:*", "waf:*", "wafv2:*", "acm:*", "globalaccelerator:*"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = ["eu-west-1", "eu-central-1", "eu-west-2"]
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy" "deny_public_s3" {
  name        = "deny-public-s3"
  description = "Empeche la desactivation du Block Public Access et l'usage d'ACLs publiques sur S3"
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyS3PublicAccessBlockDeletion"
        Effect   = "Deny"
        Action   = ["s3:DeleteBucketPublicAccessBlock", "s3:DeleteAccountPublicAccessBlock"]
        Resource = "*"
      },
      {
        Sid      = "DenyS3BlockPublicAclsFalse"
        Effect   = "Deny"
        Action   = ["s3:PutBucketPublicAccessBlock", "s3:PutAccountPublicAccessBlock"]
        Resource = "*"
        Condition = { Bool = { "s3:PublicAccessBlockConfiguration/BlockPublicAcls" = "false" } }
      },
      {
        Sid      = "DenyS3IgnorePublicAclsFalse"
        Effect   = "Deny"
        Action   = ["s3:PutBucketPublicAccessBlock", "s3:PutAccountPublicAccessBlock"]
        Resource = "*"
        Condition = { Bool = { "s3:PublicAccessBlockConfiguration/IgnorePublicAcls" = "false" } }
      },
      {
        Sid      = "DenyS3BlockPublicPolicyFalse"
        Effect   = "Deny"
        Action   = ["s3:PutBucketPublicAccessBlock", "s3:PutAccountPublicAccessBlock"]
        Resource = "*"
        Condition = { Bool = { "s3:PublicAccessBlockConfiguration/BlockPublicPolicy" = "false" } }
      },
      {
        Sid      = "DenyS3RestrictPublicBucketsFalse"
        Effect   = "Deny"
        Action   = ["s3:PutBucketPublicAccessBlock", "s3:PutAccountPublicAccessBlock"]
        Resource = "*"
        Condition = { Bool = { "s3:PublicAccessBlockConfiguration/RestrictPublicBuckets" = "false" } }
      },
      {
        Sid      = "DenyPublicBucketACLs"
        Effect   = "Deny"
        Action   = ["s3:PutBucketAcl", "s3:PutObjectAcl"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "s3:x-amz-grant-public-read"  = "true"
            "s3:x-amz-grant-public-write" = "true"
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy" "mandatory_trail" {
  name        = "mandatory-trail"
  description = "Empeche l'arret, la modification ou la suppression de CloudTrail"
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyCloudTrailModification"
        Effect   = "Deny"
        Action   = [
          "cloudtrail:DeleteTrail", "cloudtrail:StopLogging", "cloudtrail:UpdateTrail",
          "cloudtrail:PutEventSelectors", "cloudtrail:RemoveTags", "cloudtrail:AddTags"
        ]
        Resource = "*"
      }
    ]
  })
}

# --- Attachements ---

resource "aws_organizations_policy_attachment" "eu_only_attach" {
  policy_id = aws_organizations_policy.eu_only.id
  target_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_policy_attachment" "deny_public_s3_attach" {
  policy_id = aws_organizations_policy.deny_public_s3.id
  target_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_policy_attachment" "mandatory_trail_attach" {
  policy_id = aws_organizations_policy.mandatory_trail.id
  target_id = aws_organizations_organization.org.roots[0].id
}
