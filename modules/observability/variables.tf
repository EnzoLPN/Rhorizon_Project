variable "environment" {
  type        = string
  description = "Environnement cible (nonprod ou prod)"
}

variable "oidc_provider_url" {
  type        = string
  description = "URL du fournisseur OIDC EKS pour IRSA"
}

variable "oidc_provider_arn" {
  type        = string
  description = "ARN du fournisseur OIDC EKS pour IRSA"
}

variable "logs_bucket_name" {
  type        = string
  description = "Nom (ID) du bucket S3 central pour les logs d'audit"
}

variable "kms_logs_key_arn" {
  type        = string
  description = "ARN de la cle KMS de chiffrement des logs"
}

variable "aws_region" {
  type        = string
  description = "Region AWS pour configurer les flux CloudWatch et S3"
  default     = "eu-west-1"
}

variable "grafana_ingress_enabled" {
  type        = bool
  description = "Activer l'Ingress pour exposer Grafana avec un nom de domaine public"
  default     = false
}

variable "grafana_domain_name" {
  type        = string
  description = "Nom de domaine complet pour Grafana (ex: grafana.nonprod.rhorizon.xyz)"
  default     = ""
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN du certificat SSL/TLS ACM a utiliser pour l Ingress HTTPS"
  default     = ""
}

variable "waf_web_acl_arn" {
  type        = string
  description = "ARN du Web ACL WAFv2 regional pour securiser l Ingress Grafana"
  default     = ""
}
