variable "environment" {
  type        = string
  description = "Nom de l'environnement (ex: shared)"
}


variable "github_organization" {
  type        = string
  description = "Nom de l'organisation ou utilisateur GitHub (ex: EnzoLPN)"
  default     = "EnzoLPN"
}

variable "github_project" {
  type        = string
  description = "Nom du projet/depot GitHub (ex: Rhorizon_Project)"
  default     = "Rhorizon_Project"
}

variable "nonprod_account_id" {
  type        = string
  description = "ID du compte AWS Non-Prod"
}

variable "prod_account_id" {
  type        = string
  description = "ID du compte AWS Prod"
}


variable "project_name" {
  type        = string
  description = "Nom du projet (ex: rhorizon)"
  default     = "rhorizon"
}
