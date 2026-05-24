variable "environment" {
  type        = string
  description = "Nom de l'environnement (ex: shared-services)"
  default     = "shared-services"
}

variable "enable_object_lock" {
  type        = bool
  description = "Activer ou non S3 Object Lock pour le bucket de logs"
  default     = true
}

variable "object_lock_retention_days" {
  type        = number
  description = "Duree de retention pour Object Lock (en jours)"
  default     = 90
}

variable "transition_to_ia_days" {
  type        = number
  description = "Nombre de jours avant transition vers S3 Standard-IA"
  default     = 30
}

variable "transition_to_glacier_days" {
  type        = number
  description = "Nombre de jours avant transition vers Glacier"
  default     = 90
}

variable "nonprod_account_id" {
  type        = string
  description = "ID du compte AWS Non-Prod pour accorder les acces cross-account"
  default     = ""
}

variable "prod_account_id" {
  type        = string
  description = "ID du compte AWS Prod pour accorder les acces cross-account"
  default     = ""
}

variable "project_name" {
  type        = string
  description = "Nom du projet (ex: rhorizon)"
  default     = "rhorizon"
}
