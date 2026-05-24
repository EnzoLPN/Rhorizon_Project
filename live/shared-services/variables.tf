variable "aws_region" {
  type        = string
  description = "Region AWS pour le compte shared-services"
  default     = "eu-west-1"
}

variable "aws_profile" {
  type        = string
  description = "Nom du profil local AWS CLI SSO pour le compte shared-services"
  default     = "aws-shared"
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

variable "github_organization" {
  type        = string
  description = "Nom de l organisation ou utilisateur GitHub"
  default     = "EnzoLPN"
}

variable "github_project" {
  type        = string
  description = "Nom du depot de code GitHub"
  default     = "Rhorizon_Project"
}


variable "project_name" {
  type        = string
  description = "Nom du projet (ex: rhorizon)"
  default     = "rhorizon"
}

variable "enable_object_lock" {
  type        = bool
  description = "Activer ou non l'Object Lock sur les buckets S3"
  default     = true
}
