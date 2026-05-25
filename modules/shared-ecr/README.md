# 📦 Module Shared ECR

Ce module gère le registre de conteneurs ECR centralisé avec des politiques de cycle de vie et d accès cross-account pour les environnements de déploiement.

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
| [aws_ecr_lifecycle_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.cross_account_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_read_principals"></a> [allowed\_read\_principals](#input\_allowed\_read\_principals) | Liste des ARNs des roles IAM ou comptes AWS autorises a faire du Pull cross-account (lecture) | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l'environnement (ex: shared) | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN de la cle KMS centralisee de chiffrement des images | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |
| <a name="input_repository_names"></a> [repository\_names](#input\_repository\_names) | Liste des noms de depots ECR a creer | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repository_arns"></a> [repository\_arns](#output\_repository\_arns) | ARNs des depots ECR crees |
| <a name="output_repository_urls"></a> [repository\_urls](#output\_repository\_urls) | Urls de connexion pour chaque depot ECR cree |
