<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [tls_certificate.github](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

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
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | n/a |
<!-- END_TF_DOCS -->