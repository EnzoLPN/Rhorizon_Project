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
| [aws_iam_policy.github_actions_nonprod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.github_actions_prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.github_actions_nonprod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.github_actions_prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.github_nonprod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.github_prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
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
| <a name="output_github_actions_nonprod_role_arn"></a> [github\_actions\_nonprod\_role\_arn](#output\_github\_actions\_nonprod\_role\_arn) | ARN du role IAM Non-Prod a faire endosser par le runner |
| <a name="output_github_actions_prod_role_arn"></a> [github\_actions\_prod\_role\_arn](#output\_github\_actions\_prod\_role\_arn) | ARN du role IAM Prod a faire endosser par le runner |
| <a name="output_github_oidc_provider_arn"></a> [github\_oidc\_provider\_arn](#output\_github\_oidc\_provider\_arn) | ARN du fournisseur d identite OIDC GitHub |

<!-- BEGIN_TF_DOCS -->
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
| <a name="output_github_actions_nonprod_role_arn"></a> [github\_actions\_nonprod\_role\_arn](#output\_github\_actions\_nonprod\_role\_arn) | ARN du role IAM Non-Prod a faire endosser par le runner |
| <a name="output_github_actions_prod_role_arn"></a> [github\_actions\_prod\_role\_arn](#output\_github\_actions\_prod\_role\_arn) | ARN du role IAM Prod a faire endosser par le runner |
| <a name="output_github_oidc_provider_arn"></a> [github\_oidc\_provider\_arn](#output\_github\_oidc\_provider\_arn) | ARN du fournisseur d identite OIDC GitHub |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | n/a |
<!-- END_TF_DOCS -->