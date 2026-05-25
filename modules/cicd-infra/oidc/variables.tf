variable "environment" {
  type        = string
  description = "Nom de l'environnement (ex: shared)"
}

variable "project_name" {
  type        = string
  description = "Nom du projet (ex: rhorizon)"
  default     = "rhorizon"
}
