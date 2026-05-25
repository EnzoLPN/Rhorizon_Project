# 📦 Module CI/CD Infra

Ce module configure la fédération d identité OIDC pour GitHub Actions et les rôles IAM nécessaires au déploiement cross-account sécurisé.

## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_oidc"></a> [oidc](#module\_oidc) | ./oidc | n/a |
| <a name="module_source_roles"></a> [source\_roles](#module\_source\_roles) | ./source-roles | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l'environnement (ex: shared) | `string` | n/a | yes |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | Nom de l'organisation ou utilisateur GitHub (ex: EnzoLPN) | `string` | `"EnzoLPN"` | no |
| <a name="input_github_project"></a> [github\_project](#input\_github\_project) | Nom du projet/depot GitHub (ex: Rhorizon\_Project) | `string` | `"Rhorizon_Project"` | no |
| <a name="input_nonprod_account_id"></a> [nonprod\_account\_id](#input\_nonprod\_account\_id) | ID du compte AWS Non-Prod | `string` | n/a | yes |
| <a name="input_prod_account_id"></a> [prod\_account\_id](#input\_prod\_account\_id) | ID du compte AWS Prod | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_actions_nonprod_role_arn"></a> [github\_actions\_nonprod\_role\_arn](#output\_github\_actions\_nonprod\_role\_arn) | n/a |
| <a name="output_github_actions_prod_role_arn"></a> [github\_actions\_prod\_role\_arn](#output\_github\_actions\_prod\_role\_arn) | n/a |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | n/a |
