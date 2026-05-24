variable "environment" {
  type        = string
  description = "Nom de l'environnement (nonprod ou prod)"
}

variable "vpc_id" {
  type        = string
  description = "ID du VPC dans lequel déployer le bastion"
}

variable "subnet_id" {
  type        = string
  description = "ID du sous-réseau privé dans lequel positionner le bastion"
}

variable "rds_security_group_id" {
  type        = string
  description = "ID du Security Group de la base de données RDS à laquelle le bastion doit avoir accès"
}

variable "project_name" {
  type        = string
  description = "Nom du projet (ex: rhorizon)"
  default     = "rhorizon"
}
