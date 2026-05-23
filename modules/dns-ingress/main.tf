# --- Zone Route 53 Publique ---
resource "aws_route53_zone" "public" {
  count = var.create_public_zone ? 1 : 0
  name  = var.domain_name

  tags = {
    Name        = "${var.environment}-public-zone"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

data "aws_route53_zone" "existing" {
  count = var.create_public_zone ? 0 : 1
  name  = var.domain_name
}

locals {
  zone_id = var.create_public_zone ? aws_route53_zone.public[0].zone_id : data.aws_route53_zone.existing[0].zone_id
}

# --- Certificat SSL/TLS ACM ---
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain_name}"
  ]

  tags = {
    Environment = var.environment
    Project     = "RHZORION"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --- Validation DNS du Certificat ACM ---
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# --- WAFv2 Web ACL (Regional) ---
resource "aws_wafv2_web_acl" "waf" {
  name        = "${var.environment}-ingress-waf"
  description = "Regional WAF for EKS Ingress protection"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Règle 1 : Rate Limiting de base pour limiter le trafic abusif (2000 requêtes / 5 min par IP)
  rule {
    name     = "RateLimit"
    priority = 10

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.environment}-waf-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  # Règle 2 : AWS Managed Rules (Common Rule Set) - Optionnel
  dynamic "rule" {
    for_each = var.enable_extended_waf_rules ? [1] : []
    content {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 20

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.environment}-waf-common-rules"
        sampled_requests_enabled   = true
      }
    }
  }

  # Règle 3 : AWS Managed Rules SQL Injection (SQLi) - Optionnel
  dynamic "rule" {
    for_each = var.enable_extended_waf_rules ? [1] : []
    content {
      name     = "AWSManagedRulesSQLiRuleSet"
      priority = 30

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesSQLiRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.environment}-waf-sqli-rules"
        sampled_requests_enabled   = true
      }
    }
  }

  # Règle 4 : AWS Managed Rules IP Reputation (Amazon IP Reputation List) - Optionnel
  dynamic "rule" {
    for_each = var.enable_extended_waf_rules ? [1] : []
    content {
      name     = "AWSManagedRulesAmazonIpReputationList"
      priority = 40

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesAmazonIpReputationList"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.environment}-waf-ip-rep-rules"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.environment}-ingress-waf-global"
    sampled_requests_enabled   = true
  }

  tags = {
    Environment = var.environment
    Project     = "RHZORION"
  }
}
