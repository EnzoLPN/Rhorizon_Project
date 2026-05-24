# --- WAFv2 Web ACL (Regional) ---
resource "aws_wafv2_web_acl" "waf" {
  name        = "${var.project_name}-${var.environment}-ingress-waf"
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
      metric_name                = "${var.project_name}-${var.environment}-waf-rate-limit"
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
        metric_name                = "${var.project_name}-${var.environment}-waf-common-rules"
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
        metric_name                = "${var.project_name}-${var.environment}-waf-sqli-rules"
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
        metric_name                = "${var.project_name}-${var.environment}-waf-ip-rep-rules"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-${var.environment}-ingress-waf-global"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ingress-waf"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}
