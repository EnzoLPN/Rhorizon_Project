# Module : Gestion des Secrets (Secrets Management)

Ce module intègre AWS Secrets Manager avec Kubernetes via le Secrets Store CSI Driver, permettant une consommation sécurisée des secrets par les applications.

## 🛡️ Points clés de Sécurité (ASD)
*   **Intégration CSI Driver** : Les secrets sont montés directement en tant que volumes dans les Pods, évitant de les stocker dans des variables d'environnement (plus vulnérables).
*   **Chiffrement KMS** : Tous les secrets stockés dans AWS Secrets Manager sont chiffrés via une clé KMS dédiée.
*   **Isolation via IRSA** : Chaque application utilise son propre rôle IAM (via OIDC) pour accéder uniquement aux secrets dont elle a besoin, respectant le principe du moindre privilège.
*   **Auditabilité** : Tous les accès aux secrets sont tracés dans AWS CloudTrail, permettant de savoir quel Pod a accédé à quelle information et quand.
*   **Zéro Persistance Kubernetes** : Les secrets ne sont pas stockés de manière permanente dans l'etcd de Kubernetes sous forme de `Secret` natif (sauf configuration explicite), réduisant la surface d'attaque.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.secrets_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.secrets_app_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.secrets_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_secretsmanager_secret.app_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.app_secret_val](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [helm_release.aws_provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.csi_driver](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l'environnement (ex: nonprod, prod) | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN de la cle KMS pour chiffrer les secrets | `string` | `null` | no |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | ARN du fournisseur OIDC EKS pour configurer IRSA | `string` | n/a | yes |
| <a name="input_oidc_provider_url"></a> [oidc\_provider\_url](#input\_oidc\_provider\_url) | URL du fournisseur OIDC EKS pour configurer IRSA | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secrets_role_arn"></a> [secrets\_role\_arn](#output\_secrets\_role\_arn) | ARN du role IAM associe au Service Account Kubernetes pour l acces aux secrets |
| <a name="output_test_secret_arn"></a> [test\_secret\_arn](#output\_test\_secret\_arn) | ARN du secret de test cree dans AWS Secrets Manager |
| <a name="output_test_secret_name"></a> [test\_secret\_name](#output\_test\_secret\_name) | Nom du secret de test |
