terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.98"
    }
  }
}

module "accounts_baseline" {
  source = "../../modules/accounts-baseline"

  shared_services_email = var.shared_services_email
  nonprod_email         = var.nonprod_email
  prod_email            = var.prod_email
}
