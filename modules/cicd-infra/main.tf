# Ce fichier à la racine du module sert de passerelle
# pour garder une compatibilité si on appelle le module parent

module "oidc" {
  source = "./oidc"
  environment = var.environment
  project_name = var.project_name
}

module "source_roles" {
  source = "./source-roles"
  environment = var.environment
  project_name = var.project_name
  oidc_provider_arn = module.oidc.oidc_provider_arn
  github_organization = var.github_organization
  github_project = var.github_project
  nonprod_account_id = var.nonprod_account_id
  prod_account_id = var.prod_account_id
}

output "github_actions_nonprod_role_arn" {
  value = module.source_roles.github_actions_nonprod_role_arn
}

output "github_actions_prod_role_arn" {
  value = module.source_roles.github_actions_prod_role_arn
}

output "oidc_provider_arn" {
  value = module.oidc.oidc_provider_arn
}
