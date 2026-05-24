variable "environment" {
  type        = string
  description = "Nom de l'environnement (ex: shared)"
}

variable "repository_names" {
  type        = list(string)
  description = "Liste des noms de depots ECR a creer"
}

variable "kms_key_arn" {
  type        = string
  description = "ARN de la cle KMS centralisee de chiffrement des images"
}

variable "allowed_read_principals" {
  type        = list(string)
  description = "Liste des ARNs des roles IAM ou comptes AWS autorises a faire du Pull cross-account (lecture)"
  default     = []
}

variable "project_name" {
  type        = string
  description = "Nom du projet (ex: rhorizon)"
  default     = "rhorizon"
}
