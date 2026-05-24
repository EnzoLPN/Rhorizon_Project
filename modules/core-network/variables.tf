variable "environment" {
  type        = string
  description = "Nom de l'environnement (ex: nonprod, prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "Bloc CIDR pour le VPC"
}

variable "az_count" {
  type        = number
  description = "Nombre de zones de disponibilite a utiliser"
  default     = 2
}

variable "subnet_cidr_mask" {
  type        = number
  description = "Masque de sous-reseau (ex: 24 pour /24, 23 pour /23)"
  default     = 24
}

variable "nat_strategy" {
  type        = string
  description = "Strategie NAT Gateway : 'single' (une seule NAT partagee) ou 'per_az' (une NAT dediee par zone)"
  default     = "single"

  validation {
    condition     = contains(["single", "per_az"], var.nat_strategy)
    error_message = "La strategie NAT doit etre 'single' ou 'per_az'."
  }
}

variable "vpc_endpoints" {
  type        = list(string)
  description = "Liste des services AWS pour lesquels creer des VPC Endpoints d'interface"
  default     = ["sts", "ecr.api", "ecr.dkr", "kms", "secretsmanager", "logs"]
}

variable "enable_vpc_endpoints" {
  type        = bool
  description = "Activer ou non les VPC Endpoints d'interface (PrivateLink)"
  default     = true
}

variable "flow_logs_retention_days" {
  type        = number
  description = "Duree de retention des logs de flux VPC (en jours)"
  default     = 14
}

variable "enable_phz" {
  type        = bool
  description = "Activer ou non la zone DNS privee Route 53"
  default     = true
}

variable "private_domain_name" {
  type        = string
  description = "Nom de domaine de la zone DNS privee"
  default     = "rhorizon.local"
}

variable "project_name" {
  type        = string
  description = "Nom du projet (ex: rhorizon)"
  default     = "rhorizon"
}
