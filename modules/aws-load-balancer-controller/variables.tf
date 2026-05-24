variable "environment" {
  type        = string
  description = "Nom de l'environnement (ex: nonprod, prod)"
}

variable "cluster_name" {
  type        = string
  description = "Nom du cluster EKS"
}

variable "oidc_provider_url" {
  type        = string
  description = "URL du provider OIDC du cluster EKS"
}

variable "oidc_provider_arn" {
  type        = string
  description = "ARN du provider OIDC du cluster EKS"
}

variable "vpc_id" {
  type        = string
  description = "ID du VPC"
}

variable "aws_region" {
  type        = string
  description = "Région AWS"
  default     = "eu-west-1"
}

variable "project_name" {
  type        = string
  description = "Nom du projet (ex: rhorizon)"
  default     = "rhorizon"
}
