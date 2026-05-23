output "route53_zone_id" {
  description = "ID de la zone DNS publique Route 53"
  value       = local.zone_id
}

output "route53_zone_name_servers" {
  description = "Serveurs de noms (Name Servers) de la zone publique Route 53"
  value       = var.create_public_zone ? aws_route53_zone.public[0].name_servers : null
}

output "acm_certificate_arn" {
  description = "ARN du certificat SSL/TLS ACM valide"
  value       = aws_acm_certificate_validation.cert.certificate_arn
}

output "waf_web_acl_arn" {
  description = "ARN du Web ACL WAFv2 regional pour l Ingress"
  value       = aws_wafv2_web_acl.waf.arn
}
