# 📦 Module Accounts Baseline

Ce module gère la création des comptes AWS, les Organizational Units (OU), CloudTrail et les Service Control Policies (SCP) de base.

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
| [aws_cloudtrail.org_trail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_kms_alias.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_organizations_account.nonprod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_organizations_account.prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_organizations_account.shared_services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization) | resource |
| [aws_organizations_organizational_unit.nonprod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.shared](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_policy.deny_public_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy.eu_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy.mandatory_trail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy_attachment.deny_public_s3_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_organizations_policy_attachment.eu_only_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_organizations_policy_attachment.mandatory_trail_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_nonprod_email"></a> [nonprod\_email](#input\_nonprod\_email) | Adresse e-mail unique pour le compte non-production (np) | `string` | n/a | yes |
| <a name="input_prod_email"></a> [prod\_email](#input\_prod\_email) | Adresse e-mail unique pour le compte production (pr) | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |
| <a name="input_shared_services_email"></a> [shared\_services\_email](#input\_shared\_services\_email) | Adresse e-mail unique pour le compte shared-services | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_nonprod_id"></a> [account\_nonprod\_id](#output\_account\_nonprod\_id) | ID du compte nonprod |
| <a name="output_account_prod_id"></a> [account\_prod\_id](#output\_account\_prod\_id) | ID du compte prod |
| <a name="output_account_shared_services_id"></a> [account\_shared\_services\_id](#output\_account\_shared\_services\_id) | ID du compte shared-services |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | ID de l'organisation AWS |
| <a name="output_organization_root_id"></a> [organization\_root\_id](#output\_organization\_root\_id) | ID de la racine (root) de l'organisation |
| <a name="output_ou_nonprod_id"></a> [ou\_nonprod\_id](#output\_ou\_nonprod\_id) | ID de l'OU Non-Prod |
| <a name="output_ou_prod_id"></a> [ou\_prod\_id](#output\_ou\_prod\_id) | ID de l'OU Prod |
| <a name="output_ou_shared_id"></a> [ou\_shared\_id](#output\_ou\_shared\_id) | ID de l'OU Shared |
