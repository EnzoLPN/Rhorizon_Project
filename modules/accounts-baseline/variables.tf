variable "shared_services_email" {
  type        = string
  description = "Adresse e-mail unique pour le compte shared-services"
}

variable "nonprod_email" {
  type        = string
  description = "Adresse e-mail unique pour le compte non-production (np)"
}

variable "prod_email" {
  type        = string
  description = "Adresse e-mail unique pour le compte production (pr)"
}
