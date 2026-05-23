variable "environment" {
  type        = string
  description = "Nom de l'environnement (ex: nonprod, prod)"
}

variable "vpc_id" {
  type        = string
  description = "ID du VPC dans lequel déployer le cluster EKS"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Liste des sous-reseaux prives (applicatifs) pour EKS"
}

variable "kubernetes_version" {
  type        = string
  description = "Version de Kubernetes pour le cluster EKS"
  default     = "1.31"
}

variable "instance_types" {
  type        = list(string)
  description = "Liste des types d'instances pour les noeuds EKS"
  default     = ["t3.medium"]
}

variable "desired_size" {
  type        = number
  description = "Nombre souhaite de noeuds dans le groupe de noeuds"
  default     = 2
}

variable "min_size" {
  type        = number
  description = "Nombre minimal de noeuds dans le groupe"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "Nombre maximal de noeuds dans le groupe"
  default     = 3
}
