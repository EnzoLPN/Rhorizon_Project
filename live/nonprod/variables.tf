variable "aws_region" {
  type        = string
  description = "Région AWS"
  default     = "eu-west-1"
}

variable "aws_profile" {
  type        = string
  description = "Profil AWS CLI SSO pour le compte nonprod"
  default     = "aws-nonprod"
}

variable "environment" {
  type        = string
  description = "Nom de l'environnement"
  default     = "nonprod"
}

# --- Network ---
variable "vpc_cidr" {
  type        = string
  description = "CIDR block du VPC"
  default     = "10.10.0.0/16"
}

variable "az_count" {
  type        = number
  description = "Nombre de zones de disponibilité"
  default     = 2
}

variable "subnet_cidr_mask" {
  type        = number
  description = "Masque de sous-réseau"
  default     = 24
}

variable "nat_strategy" {
  type        = string
  description = "Stratégie NAT (single ou per_az)"
  default     = "single"
}

variable "private_domain_name" {
  type        = string
  description = "Nom de domaine privé Route53"
  default     = "np.rhorizon.local"
}

# --- DNS Ingress ---
variable "domain_name" {
  type        = string
  description = "Nom de domaine public principal"
  default     = "nonprod.rhorizon.xyz"
}

# --- EKS ---
variable "kubernetes_version" {
  type        = string
  description = "Version de Kubernetes pour EKS"
  default     = "1.32"
}

variable "eks_instance_types" {
  type        = list(string)
  description = "Types d'instances EC2 pour les noeuds EKS"
  default     = ["t3.medium"]
}

variable "eks_desired_size" {
  type        = number
  description = "Nombre de noeuds EKS souhaité"
  default     = 1
}

variable "eks_min_size" {
  type        = number
  description = "Nombre minimum de noeuds EKS"
  default     = 1
}

variable "eks_max_size" {
  type        = number
  description = "Nombre maximum de noeuds EKS"
  default     = 2
}

# --- RDS ---
variable "db_admin_password" {
  type        = string
  description = "Mot de passe de l'administrateur de la base de données"
  sensitive   = true
  default     = "RHZorionDevPass2026!"
}

# --- Shared Services (remote state) ---
variable "shared_services_state_path" {
  type        = string
  description = "Chemin vers le fichier tfstate de shared-services"
  default     = "../shared-services/terraform.tfstate"
}
