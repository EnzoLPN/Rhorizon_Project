variable "environment" {
  type        = string
  description = "Nom de l'environnement (ex: nonprod, prod)"
}

variable "domain_name" {
  type        = string
  description = "Nom de domaine public à gérer (ex: nonprod.rhorizon.xyz ou rhorizon.xyz)"
}

variable "create_public_zone" {
  type        = bool
  description = "Indique s'il faut creer la zone Route 53 publique (true) ou utiliser une zone existante (false)"
  default     = true
}

variable "enable_extended_waf_rules" {
  type        = bool
  description = "Activer les regles de protection WAFv2 etendues (recommande pour la prod)"
  default     = false
}
