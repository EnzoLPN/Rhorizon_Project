# Module : Base de Données RDS (PostgreSQL)

Ce module provisionne une instance Amazon RDS pour PostgreSQL, sécurisée et isolée dans le tier "Data" de l'infrastructure.

## 🛡️ Points clés de Sécurité (ASD)
*   **Isolement Réseau** : L'instance est déployée dans des sous-réseaux de données privés, sans aucun accès direct depuis Internet.
*   **Chiffrement au Repos** : Le stockage de la base de données est systématiquement chiffré via AWS KMS.
*   **Gestion des Secrets** : Le mot de passe administrateur est généré aléatoirement et stocké de manière sécurisée dans AWS Secrets Manager, évitant toute fuite dans le code source.
*   **Authentification IAM** : Possibilité d'étendre l'authentification à IAM pour supprimer le besoin de mots de passe statiques pour les applications.
*   **Backups & Rétention** : Configuration automatique des sauvegardes avec une période de rétention définie pour garantir la résilience des données.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.postgres](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_secretsmanager_secret.rds_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.rds_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [random_password.db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Mot de passe administrateur (obsolète, géré via Secrets Manager) | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Nom de l'administrateur de la base de donnees | `string` | `"dbadmin"` | no |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Taille initiale du stockage en Go | `number` | `20` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Duree de retention des backups automatiques (en jours) | `number` | `7` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Nom de la base de donnees par defaut a creer | `string` | `"rhorizon"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Proteger la base de donnees contre les suppressions accidentelles | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l'environnement (ex: nonprod, prod) | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Classe d'instance de la base de donnees RDS | `string` | `"db.t4g.micro"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN de la cle KMS pour le chiffrement du stockage (si storage\_encrypted est true). Si vide, utilise la cle par defaut d'AWS RDS. | `string` | `""` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Taille maximale du stockage pour l'autoscaling en Go (0 pour desactiver) | `number` | `100` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Activer la haute disponibilite multi-AZ | `bool` | `false` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |
| <a name="input_rds_security_group_id"></a> [rds\_security\_group\_id](#input\_rds\_security\_group\_id) | ID du Security Group RDS a associer a l'instance | `string` | n/a | yes |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Passer la creation du snapshot final lors de la destruction | `bool` | `true` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Activer le chiffrement du stockage au repos | `bool` | `true` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Liste des IDs de sous-reseaux pour le Subnet Group RDS | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_instance_address"></a> [db\_instance\_address](#output\_db\_instance\_address) | Adresse DNS interne de l'instance de base de donnees |
| <a name="output_db_instance_arn"></a> [db\_instance\_arn](#output\_db\_instance\_arn) | ARN de la base de données |
| <a name="output_db_instance_endpoint"></a> [db\_instance\_endpoint](#output\_db\_instance\_endpoint) | Endpoint de connexion a la base de donnees (format hote:port) |
| <a name="output_db_instance_name"></a> [db\_instance\_name](#output\_db\_instance\_name) | Nom de la base de donnees creee |
| <a name="output_db_instance_port"></a> [db\_instance\_port](#output\_db\_instance\_port) | Port d'ecoute de la base de donnees (5432) |
| <a name="output_db_instance_username"></a> [db\_instance\_username](#output\_db\_instance\_username) | Nom d'utilisateur de l'administrateur de la base de donnees |

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.postgres](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_secretsmanager_secret.rds_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.rds_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group_rule.ingress_external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [random_password.db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Mot de passe administrateur (obsolète, géré via Secrets Manager) | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Nom de l'administrateur de la base de donnees | `string` | `"dbadmin"` | no |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Taille initiale du stockage en Go | `number` | `20` | no |
| <a name="input_allowed_security_group_id"></a> [allowed\_security\_group\_id](#input\_allowed\_security\_group\_id) | ID du Security Group externe (ex: EKS) a autoriser sur le port 5432 | `string` | `""` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Duree de retention des backups automatiques (en jours) | `number` | `7` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Nom de la base de donnees par defaut a creer | `string` | `"rhorizon"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Proteger la base de donnees contre les suppressions accidentelles | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l'environnement (ex: nonprod, prod) | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Classe d'instance de la base de donnees RDS | `string` | `"db.t4g.micro"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN de la cle KMS pour le chiffrement du stockage (si storage\_encrypted est true). Si vide, utilise la cle par defaut d'AWS RDS. | `string` | `""` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Taille maximale du stockage pour l'autoscaling en Go (0 pour desactiver) | `number` | `100` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Activer la haute disponibilite multi-AZ | `bool` | `false` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |
| <a name="input_rds_security_group_id"></a> [rds\_security\_group\_id](#input\_rds\_security\_group\_id) | ID du Security Group RDS a associer a l'instance | `string` | n/a | yes |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Passer la creation du snapshot final lors de la destruction | `bool` | `true` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Activer le chiffrement du stockage au repos | `bool` | `true` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Liste des IDs de sous-reseaux pour le Subnet Group RDS | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_instance_address"></a> [db\_instance\_address](#output\_db\_instance\_address) | Adresse DNS interne de l'instance de base de donnees |
| <a name="output_db_instance_arn"></a> [db\_instance\_arn](#output\_db\_instance\_arn) | ARN de la base de données |
| <a name="output_db_instance_endpoint"></a> [db\_instance\_endpoint](#output\_db\_instance\_endpoint) | Endpoint de connexion a la base de donnees (format hote:port) |
| <a name="output_db_instance_name"></a> [db\_instance\_name](#output\_db\_instance\_name) | Nom de la base de donnees creee |
| <a name="output_db_instance_port"></a> [db\_instance\_port](#output\_db\_instance\_port) | Port d'ecoute de la base de donnees (5432) |
| <a name="output_db_instance_username"></a> [db\_instance\_username](#output\_db\_instance\_username) | Nom d'utilisateur de l'administrateur de la base de donnees |
<!-- END_TF_DOCS -->