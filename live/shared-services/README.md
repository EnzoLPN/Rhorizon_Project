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
| <a name="module_cicd_infra"></a> [cicd\_infra](#module\_cicd\_infra) | ../../modules/cicd-infra | n/a |
| <a name="module_shared_core"></a> [shared\_core](#module\_shared\_core) | ../../modules/shared-core | n/a |
| <a name="module_shared_ecr"></a> [shared\_ecr](#module\_shared\_ecr) | ../../modules/shared-ecr | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | Nom du profil local AWS CLI SSO pour le compte shared-services | `string` | `"aws-shared"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region AWS pour le compte shared-services | `string` | `"eu-west-1"` | no |
| <a name="input_enable_object_lock"></a> [enable\_object\_lock](#input\_enable\_object\_lock) | Activer ou non l'Object Lock sur les buckets S3 | `bool` | `true` | no |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | Nom de l organisation ou utilisateur GitHub | `string` | `"EnzoLPN"` | no |
| <a name="input_github_project"></a> [github\_project](#input\_github\_project) | Nom du depot de code GitHub | `string` | `"Rhorizon_Project"` | no |
| <a name="input_nonprod_account_id"></a> [nonprod\_account\_id](#input\_nonprod\_account\_id) | ID du compte AWS Non-Prod pour accorder les acces cross-account | `string` | `""` | no |
| <a name="input_prod_account_id"></a> [prod\_account\_id](#input\_prod\_account\_id) | ID du compte AWS Prod pour accorder les acces cross-account | `string` | `""` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_assets_arn"></a> [bucket\_assets\_arn](#output\_bucket\_assets\_arn) | ARN du bucket S3 d'assets centralises |
| <a name="output_bucket_assets_id"></a> [bucket\_assets\_id](#output\_bucket\_assets\_id) | Nom (ID) du bucket S3 d'assets centralises |
| <a name="output_bucket_backups_arn"></a> [bucket\_backups\_arn](#output\_bucket\_backups\_arn) | ARN du bucket S3 de backups centralises |
| <a name="output_bucket_backups_id"></a> [bucket\_backups\_id](#output\_bucket\_backups\_id) | Nom (ID) du bucket S3 de backups centralises |
| <a name="output_bucket_logs_arn"></a> [bucket\_logs\_arn](#output\_bucket\_logs\_arn) | ARN du bucket S3 de logs centralises |
| <a name="output_bucket_logs_id"></a> [bucket\_logs\_id](#output\_bucket\_logs\_id) | Nom (ID) du bucket S3 de logs centralises |
| <a name="output_ecr_repository_arns"></a> [ecr\_repository\_arns](#output\_ecr\_repository\_arns) | ARNs des depots ECR centraux |
| <a name="output_ecr_repository_urls"></a> [ecr\_repository\_urls](#output\_ecr\_repository\_urls) | Urls de connexion pour chaque depot ECR central |
| <a name="output_github_actions_nonprod_role_arn"></a> [github\_actions\_nonprod\_role\_arn](#output\_github\_actions\_nonprod\_role\_arn) | ARN du role IAM Non-Prod a faire endosser par le runner |
| <a name="output_github_actions_prod_role_arn"></a> [github\_actions\_prod\_role\_arn](#output\_github\_actions\_prod\_role\_arn) | ARN du role IAM Prod a faire endosser par le runner |
| <a name="output_kms_assets_key_arn"></a> [kms\_assets\_key\_arn](#output\_kms\_assets\_key\_arn) | ARN de la cle KMS de chiffrement des assets |
| <a name="output_kms_backups_key_arn"></a> [kms\_backups\_key\_arn](#output\_kms\_backups\_key\_arn) | ARN de la cle KMS de chiffrement des backups |
| <a name="output_kms_logs_key_arn"></a> [kms\_logs\_key\_arn](#output\_kms\_logs\_key\_arn) | ARN de la cle KMS de chiffrement des logs |
<!-- END_TF_DOCS -->