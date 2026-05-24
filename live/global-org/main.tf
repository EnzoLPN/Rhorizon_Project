module "accounts_baseline" {
  source = "../../modules/accounts-baseline"

  shared_services_email = var.shared_services_email
  nonprod_email         = var.nonprod_email
  prod_email            = var.prod_email
  project_name          = var.project_name
}
