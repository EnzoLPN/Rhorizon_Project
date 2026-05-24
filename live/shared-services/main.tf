module "shared_core" {
  source = "../../modules/shared-core"

  enable_object_lock         = var.enable_object_lock
  object_lock_retention_days = 90
  transition_to_ia_days      = 30
  transition_to_glacier_days = 90

  # IDs de comptes pour configurer les acces cross-account (depose de logs/sauvegardes)
  nonprod_account_id = var.nonprod_account_id
  prod_account_id    = var.prod_account_id
  project_name       = var.project_name
}

# Module centralise de registre de conteneurs (shared-ecr - Module 10.7)
module "shared_ecr" {
  source = "../../modules/shared-ecr"

  environment      = "shared"
  repository_names = ["${var.project_name}/frontend", "${var.project_name}/backend"]
  kms_key_arn      = module.shared_core.kms_assets_key_arn

  # Autorisation de pull cross-account pour les comptes applicatifs (Non-Prod & Prod)
  allowed_read_principals = [
    "arn:aws:iam::${var.nonprod_account_id}:root",
    "arn:aws:iam::${var.prod_account_id}:root"
  ]
}

# Module centralise OIDC et securite CI/CD (cicd-infra - Module 10.8)
module "cicd_infra" {
  source = "../../modules/cicd-infra"

  environment         = "shared"
  github_organization = var.github_organization
  github_project      = var.github_project
  nonprod_account_id  = var.nonprod_account_id
  prod_account_id     = var.prod_account_id
  project_name        = var.project_name
}
