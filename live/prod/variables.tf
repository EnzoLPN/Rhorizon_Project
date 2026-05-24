variable "aws_region" {
  type        = string
  description = "Région AWS"
  default     = "eu-west-1"
}

variable "aws_profile" {
  type        = string
  description = "Profil AWS CLI SSO pour le compte prod"
  default     = "aws-prod"
}

variable "environment" {
  type        = string
  description = "Nom de l'environnement"
  default     = "prod"
}

# --- Network ---
variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "az_count" {
  type    = number
  default = 3
}

variable "subnet_cidr_mask" {
  type    = number
  default = 23
}

variable "nat_strategy" {
  type    = string
  default = "per_az"
}

variable "private_domain_name" {
  type    = string
  default = "pr.rhorizon.local"
}

# --- DNS Ingress ---
variable "domain_name" {
  type    = string
  default = "rhorizon.xyz"
}

# --- EKS ---
variable "kubernetes_version" {
  type    = string
  default = "1.32"
}

variable "eks_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "eks_desired_size" {
  type    = number
  default = 3
}

variable "eks_min_size" {
  type    = number
  default = 3
}

variable "eks_max_size" {
  type    = number
  default = 6
}

# --- RDS ---
variable "db_admin_password" {
  type      = string
  sensitive = true
}

# --- Shared Services (remote state) ---
variable "shared_services_state_path" {
  type    = string
  default = "../shared-services/terraform.tfstate"
}

variable "project_name" {
  type        = string
  description = "Nom du projet (ex: rhorizon)"
  default     = "rhorizon"
}
