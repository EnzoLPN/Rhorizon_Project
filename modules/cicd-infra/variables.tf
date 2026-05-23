variable "environment" {
  type        = string
  description = "Nom de l'environnement (ex: shared)"
}

variable "gitlab_organization" {
  type        = string
  description = "Nom de l'organisation ou du groupe GitLab (ex: rhzorion-org)"
  default     = "rhzorion-org"
}

variable "gitlab_project" {
  type        = string
  description = "Nom du projet/depot GitLab (ex: infrastructure)"
  default     = "infrastructure"
}
