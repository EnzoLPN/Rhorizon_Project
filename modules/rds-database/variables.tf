variable "environment" {
  type        = string
  description = "Nom de l'environnement (ex: nonprod, prod)"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Liste des IDs de sous-reseaux pour le Subnet Group RDS"
}

variable "rds_security_group_id" {
  type        = string
  description = "ID du Security Group RDS a associer a l'instance"
}

variable "allocated_storage" {
  type        = number
  description = "Taille initiale du stockage en Go"
  default     = 20
}

variable "max_allocated_storage" {
  type        = number
  description = "Taille maximale du stockage pour l'autoscaling en Go (0 pour desactiver)"
  default     = 100
}

variable "instance_class" {
  type        = string
  description = "Classe d'instance de la base de donnees RDS"
  default     = "db.t4g.micro"
}

variable "db_name" {
  type        = string
  description = "Nom de la base de donnees par defaut a creer"
  default     = "rhorizon"
}

variable "admin_username" {
  type        = string
  description = "Nom de l'administrateur de la base de donnees"
  default     = "dbadmin"
}

variable "admin_password" {
  type        = string
  description = "Mot de passe administrateur (obsolète, géré via Secrets Manager)"
  sensitive   = true
  default     = null
}


variable "multi_az" {
  type        = bool
  description = "Activer la haute disponibilite multi-AZ"
  default     = false
}

variable "backup_retention_period" {
  type        = number
  description = "Duree de retention des backups automatiques (en jours)"
  default     = 7
}

variable "deletion_protection" {
  type        = bool
  description = "Proteger la base de donnees contre les suppressions accidentelles"
  default     = false
}

variable "storage_encrypted" {
  type        = bool
  description = "Activer le chiffrement du stockage au repos"
  default     = true
}

variable "kms_key_arn" {
  type        = string
  description = "ARN de la cle KMS pour le chiffrement du stockage (si storage_encrypted est true). Si vide, utilise la cle par defaut d'AWS RDS."
  default     = ""
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Passer la creation du snapshot final lors de la destruction"
  default     = true
}

variable "project_name" {
  type        = string
  description = "Nom du projet (ex: rhorizon)"
  default     = "rhorizon"
}

variable "allowed_security_group_id" {
  type        = string
  description = "ID du Security Group externe (ex: EKS) a autoriser sur le port 5432"
  default     = ""
}

variable "create_external_ingress_rule" {
  type        = bool
  description = "Indique s'il faut créer la règle d'ingress pour le Security Group externe"
  default     = false
}
