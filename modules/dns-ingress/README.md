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
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_route53_record.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_wafv2_web_acl.waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_route53_zone.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_public_zone"></a> [create\_public\_zone](#input\_create\_public\_zone) | Indique s'il faut creer la zone Route 53 publique (true) ou utiliser une zone existante (false) | `bool` | `true` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Nom de domaine public à gérer (ex: nonprod.rhorizon.xyz ou rhorizon.xyz) | `string` | n/a | yes |
| <a name="input_enable_extended_waf_rules"></a> [enable\_extended\_waf\_rules](#input\_enable\_extended\_waf\_rules) | Activer les regles de protection WAFv2 etendues (recommande pour la prod) | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l'environnement (ex: nonprod, prod) | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | ARN du certificat SSL/TLS ACM valide |
| <a name="output_route53_zone_id"></a> [route53\_zone\_id](#output\_route53\_zone\_id) | ID de la zone DNS publique Route 53 |
| <a name="output_route53_zone_name_servers"></a> [route53\_zone\_name\_servers](#output\_route53\_zone\_name\_servers) | Serveurs de noms (Name Servers) de la zone publique Route 53 |
| <a name="output_waf_web_acl_arn"></a> [waf\_web\_acl\_arn](#output\_waf\_web\_acl\_arn) | ARN du Web ACL WAFv2 regional pour l Ingress |

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_aws.shared"></a> [aws.shared](#provider\_aws.shared) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_route53_record.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.delegation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_wafv2_web_acl.waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_route53_zone.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_route53_zone.parent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_public_zone"></a> [create\_public\_zone](#input\_create\_public\_zone) | Indique s'il faut creer la zone Route 53 publique (true) ou utiliser une zone existante (false) | `bool` | `true` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Nom de domaine public à gérer (ex: nonprod.rhorizon.xyz ou rhorizon.xyz) | `string` | n/a | yes |
| <a name="input_enable_extended_waf_rules"></a> [enable\_extended\_waf\_rules](#input\_enable\_extended\_waf\_rules) | Activer les regles de protection WAFv2 etendues (recommande pour la prod) | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l'environnement (ex: nonprod, prod) | `string` | n/a | yes |
| <a name="input_parent_zone_name"></a> [parent\_zone\_name](#input\_parent\_zone\_name) | Nom de la zone DNS parente (ex: rhorizon.xyz) pour la délégation | `string` | `""` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | ARN du certificat SSL/TLS ACM valide |
| <a name="output_route53_zone_id"></a> [route53\_zone\_id](#output\_route53\_zone\_id) | ID de la zone Route 53 creee ou existante |
| <a name="output_route53_zone_name_servers"></a> [route53\_zone\_name\_servers](#output\_route53\_zone\_name\_servers) | Liste des serveurs de noms de la zone creee |
| <a name="output_waf_web_acl_arn"></a> [waf\_web\_acl\_arn](#output\_waf\_web\_acl\_arn) | ARN du Web ACL WAFv2 regional pour l Ingress |
<!-- END_TF_DOCS -->