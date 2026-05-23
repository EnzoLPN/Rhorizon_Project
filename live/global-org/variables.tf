variable "aws_region" {
  type        = string
  description = "Région AWS pour le compte master"
  default     = "eu-west-1"
}

variable "aws_profile" {
  type        = string
  description = "Profil AWS CLI SSO pour le compte master"
  default     = "aws-master"
}

variable "shared_services_email" {
  type        = string
  description = "E-mail unique pour le compte shared-services"
}

variable "nonprod_email" {
  type        = string
  description = "E-mail unique pour le compte non-prod"
}

variable "prod_email" {
  type        = string
  description = "E-mail unique pour le compte prod"
}
