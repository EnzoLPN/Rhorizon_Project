variable "environment" {
  type        = string
  description = "Nom de l'environnement (ex: nonprod, prod)"
}

variable "oidc_provider_url" {
  type        = string
  description = "URL du fournisseur OIDC EKS pour configurer IRSA"
}

variable "oidc_provider_arn" {
  type        = string
  description = "ARN du fournisseur OIDC EKS pour configurer IRSA"
}

variable "kms_key_arn" {
  type        = string
  description = "ARN de la cle KMS pour chiffrer les secrets"
  default     = null
}
