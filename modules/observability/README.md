## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.fluent_bit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.fluent_bit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.fluent_bit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [kubernetes_namespace_v1.logging](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.monitoring](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_storage_class_v1.gp3_encrypted](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | ARN du certificat SSL/TLS ACM a utiliser pour l Ingress HTTPS | `string` | `""` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region AWS pour configurer les flux CloudWatch et S3 | `string` | `"eu-west-1"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environnement cible (nonprod ou prod) | `string` | n/a | yes |
| <a name="input_grafana_domain_name"></a> [grafana\_domain\_name](#input\_grafana\_domain\_name) | Nom de domaine complet pour Grafana (ex: grafana.nonprod.rhorizon.xyz) | `string` | `""` | no |
| <a name="input_grafana_ingress_enabled"></a> [grafana\_ingress\_enabled](#input\_grafana\_ingress\_enabled) | Activer l'Ingress pour exposer Grafana avec un nom de domaine public | `bool` | `false` | no |
| <a name="input_kms_logs_key_arn"></a> [kms\_logs\_key\_arn](#input\_kms\_logs\_key\_arn) | ARN de la cle KMS de chiffrement des logs | `string` | n/a | yes |
| <a name="input_logs_bucket_name"></a> [logs\_bucket\_name](#input\_logs\_bucket\_name) | Nom (ID) du bucket S3 central pour les logs d'audit | `string` | n/a | yes |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | ARN du fournisseur OIDC EKS pour IRSA | `string` | n/a | yes |
| <a name="input_oidc_provider_url"></a> [oidc\_provider\_url](#input\_oidc\_provider\_url) | URL du fournisseur OIDC EKS pour IRSA | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |
| <a name="input_waf_web_acl_arn"></a> [waf\_web\_acl\_arn](#input\_waf\_web\_acl\_arn) | ARN du Web ACL WAFv2 regional pour securiser l Ingress Grafana | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fluent_bit_role_arn"></a> [fluent\_bit\_role\_arn](#output\_fluent\_bit\_role\_arn) | ARN du role IAM attribue a Fluent Bit (IRSA) |

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.fluent_bit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.fluent_bit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.fluent_bit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_route53_record.grafana](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [helm_release.fluent_bit](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.prometheus](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace_v1.logging](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.monitoring](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_storage_class_v1.gp3_encrypted](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [kubernetes_ingress_v1.grafana](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/ingress_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | ARN du certificat SSL/TLS ACM a utiliser pour l Ingress HTTPS | `string` | `""` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region AWS pour configurer les flux CloudWatch et S3 | `string` | `"eu-west-1"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environnement cible (nonprod ou prod) | `string` | n/a | yes |
| <a name="input_grafana_domain_name"></a> [grafana\_domain\_name](#input\_grafana\_domain\_name) | Nom de domaine complet pour Grafana (ex: grafana.nonprod.rhorizon.xyz) | `string` | `""` | no |
| <a name="input_grafana_ingress_enabled"></a> [grafana\_ingress\_enabled](#input\_grafana\_ingress\_enabled) | Activer l'Ingress pour exposer Grafana avec un nom de domaine public | `bool` | `false` | no |
| <a name="input_kms_logs_key_arn"></a> [kms\_logs\_key\_arn](#input\_kms\_logs\_key\_arn) | ARN de la cle KMS de chiffrement des logs | `string` | n/a | yes |
| <a name="input_logs_bucket_name"></a> [logs\_bucket\_name](#input\_logs\_bucket\_name) | Nom (ID) du bucket S3 central pour les logs d'audit | `string` | n/a | yes |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | ARN du fournisseur OIDC EKS pour IRSA | `string` | n/a | yes |
| <a name="input_oidc_provider_url"></a> [oidc\_provider\_url](#input\_oidc\_provider\_url) | URL du fournisseur OIDC EKS pour IRSA | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | ID de la zone Route 53 où créer l'enregistrement Grafana | `string` | `""` | no |
| <a name="input_waf_web_acl_arn"></a> [waf\_web\_acl\_arn](#input\_waf\_web\_acl\_arn) | ARN du Web ACL WAFv2 regional pour securiser l Ingress Grafana | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fluent_bit_role_arn"></a> [fluent\_bit\_role\_arn](#output\_fluent\_bit\_role\_arn) | ARN du role IAM attribue a Fluent Bit (IRSA) |
<!-- END_TF_DOCS -->