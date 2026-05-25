<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.98 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_accounts_baseline"></a> [accounts\_baseline](#module\_accounts\_baseline) | ../../modules/accounts-baseline | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | Profil AWS CLI SSO pour le compte master | `string` | `"aws-master"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Région AWS pour le compte master | `string` | `"eu-west-1"` | no |
| <a name="input_nonprod_email"></a> [nonprod\_email](#input\_nonprod\_email) | E-mail unique pour le compte non-prod | `string` | n/a | yes |
| <a name="input_prod_email"></a> [prod\_email](#input\_prod\_email) | E-mail unique pour le compte prod | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |
| <a name="input_shared_services_email"></a> [shared\_services\_email](#input\_shared\_services\_email) | E-mail unique pour le compte shared-services | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->