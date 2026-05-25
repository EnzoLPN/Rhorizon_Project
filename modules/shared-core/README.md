# Module : Socle Commun (Shared Core)

Ce module déploie les ressources fondamentales de sécurité et de stockage centralisé pour l'ensemble de l'organisation AWS.

## 🛡️ Points clés de Sécurité (ASD)
*   **Chiffrement KMS Centralisé** : Création et gestion de clés KMS dédiées (Logs, Backups, Assets) avec rotation automatique et politiques d'accès restrictives.
*   **S3 Public Access Block** : Activation systématique du blocage de tout accès public au niveau du bucket et du compte pour prévenir les fuites de données.
*   **S3 Object Lock** : Configuration du bucket de logs avec la fonction Object Lock en mode "Compliance" ou "Governance", garantissant l'intégrité et l'immutabilité des journaux d'audit (protection contre la suppression ou la modification malveillante).
*   **Versioning S3** : Activation du versionnement sur tous les buckets pour permettre la récupération de données en cas de suppression accidentelle ou d'attaque.
*   **Politiques Cross-Account** : Configuration fine des Bucket Policies pour autoriser uniquement les comptes applicatifs (Prod/Non-Prod) à écrire leurs logs et sauvegardes, sans accès réciproque.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_object_lock_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration) | resource |
| [aws_s3_bucket_policy.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_object_lock"></a> [enable\_object\_lock](#input\_enable\_object\_lock) | Activer ou non S3 Object Lock pour le bucket de logs | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l'environnement (ex: shared-services) | `string` | `"shared-services"` | no |
| <a name="input_nonprod_account_id"></a> [nonprod\_account\_id](#input\_nonprod\_account\_id) | ID du compte AWS Non-Prod pour accorder les acces cross-account | `string` | `""` | no |
| <a name="input_object_lock_retention_days"></a> [object\_lock\_retention\_days](#input\_object\_lock\_retention\_days) | Duree de retention pour Object Lock (en jours) | `number` | `90` | no |
| <a name="input_prod_account_id"></a> [prod\_account\_id](#input\_prod\_account\_id) | ID du compte AWS Prod pour accorder les acces cross-account | `string` | `""` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |
| <a name="input_transition_to_glacier_days"></a> [transition\_to\_glacier\_days](#input\_transition\_to\_glacier\_days) | Nombre de jours avant transition vers Glacier | `number` | `90` | no |
| <a name="input_transition_to_ia_days"></a> [transition\_to\_ia\_days](#input\_transition\_to\_ia\_days) | Nombre de jours avant transition vers S3 Standard-IA | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_assets_arn"></a> [bucket\_assets\_arn](#output\_bucket\_assets\_arn) | ARN du bucket S3 d'assets centralises |
| <a name="output_bucket_assets_id"></a> [bucket\_assets\_id](#output\_bucket\_assets\_id) | Nom (ID) du bucket S3 d'assets centralises |
| <a name="output_bucket_backups_arn"></a> [bucket\_backups\_arn](#output\_bucket\_backups\_arn) | ARN du bucket S3 de backups centralises |
| <a name="output_bucket_backups_id"></a> [bucket\_backups\_id](#output\_bucket\_backups\_id) | Nom (ID) du bucket S3 de backups centralises |
| <a name="output_bucket_logs_arn"></a> [bucket\_logs\_arn](#output\_bucket\_logs\_arn) | ARN du bucket S3 de logs centralises |
| <a name="output_bucket_logs_id"></a> [bucket\_logs\_id](#output\_bucket\_logs\_id) | Nom (ID) du bucket S3 de logs centralises |
| <a name="output_kms_assets_key_arn"></a> [kms\_assets\_key\_arn](#output\_kms\_assets\_key\_arn) | ARN de la cle KMS de chiffrement des assets |
| <a name="output_kms_backups_key_arn"></a> [kms\_backups\_key\_arn](#output\_kms\_backups\_key\_arn) | ARN de la cle KMS de chiffrement des backups |
| <a name="output_kms_logs_key_arn"></a> [kms\_logs\_key\_arn](#output\_kms\_logs\_key\_arn) | ARN de la cle KMS de chiffrement des logs |

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_object_lock_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration) | resource |
| [aws_s3_bucket_policy.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.backups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_object_lock"></a> [enable\_object\_lock](#input\_enable\_object\_lock) | Activer ou non S3 Object Lock pour le bucket de logs | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l'environnement (ex: shared-services) | `string` | `"shared-services"` | no |
| <a name="input_nonprod_account_id"></a> [nonprod\_account\_id](#input\_nonprod\_account\_id) | ID du compte AWS Non-Prod pour accorder les acces cross-account | `string` | `""` | no |
| <a name="input_object_lock_retention_days"></a> [object\_lock\_retention\_days](#input\_object\_lock\_retention\_days) | Duree de retention pour Object Lock (en jours) | `number` | `90` | no |
| <a name="input_prod_account_id"></a> [prod\_account\_id](#input\_prod\_account\_id) | ID du compte AWS Prod pour accorder les acces cross-account | `string` | `""` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |
| <a name="input_transition_to_glacier_days"></a> [transition\_to\_glacier\_days](#input\_transition\_to\_glacier\_days) | Nombre de jours avant transition vers Glacier | `number` | `90` | no |
| <a name="input_transition_to_ia_days"></a> [transition\_to\_ia\_days](#input\_transition\_to\_ia\_days) | Nombre de jours avant transition vers S3 Standard-IA | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_assets_arn"></a> [bucket\_assets\_arn](#output\_bucket\_assets\_arn) | ARN du bucket S3 d'assets centralises |
| <a name="output_bucket_assets_id"></a> [bucket\_assets\_id](#output\_bucket\_assets\_id) | Nom (ID) du bucket S3 d'assets centralises |
| <a name="output_bucket_backups_arn"></a> [bucket\_backups\_arn](#output\_bucket\_backups\_arn) | ARN du bucket S3 de backups centralises |
| <a name="output_bucket_backups_id"></a> [bucket\_backups\_id](#output\_bucket\_backups\_id) | Nom (ID) du bucket S3 de backups centralises |
| <a name="output_bucket_logs_arn"></a> [bucket\_logs\_arn](#output\_bucket\_logs\_arn) | ARN du bucket S3 de logs centralises |
| <a name="output_bucket_logs_id"></a> [bucket\_logs\_id](#output\_bucket\_logs\_id) | Nom (ID) du bucket S3 de logs centralises |
| <a name="output_kms_assets_key_arn"></a> [kms\_assets\_key\_arn](#output\_kms\_assets\_key\_arn) | ARN de la cle KMS de chiffrement des assets |
| <a name="output_kms_backups_key_arn"></a> [kms\_backups\_key\_arn](#output\_kms\_backups\_key\_arn) | ARN de la cle KMS de chiffrement des backups |
| <a name="output_kms_logs_key_arn"></a> [kms\_logs\_key\_arn](#output\_kms\_logs\_key\_arn) | ARN de la cle KMS de chiffrement des logs |
<!-- END_TF_DOCS -->