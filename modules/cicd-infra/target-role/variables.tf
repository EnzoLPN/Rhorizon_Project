variable "role_name" {
  type        = string
  description = "Nom du role IAM de deploiement a creer"
}

variable "trusted_role_arn" {
  type        = string
  description = "ARN du role source (dans le compte Shared) autorise a endosser ce role"
}

variable "environment" {
  type        = string
  description = "Environnement (nonprod, prod)"
}

variable "project_name" {
  type        = string
  description = "Nom du projet"
}
