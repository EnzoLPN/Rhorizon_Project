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
| [aws_iam_role.deploy_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.deploy_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environnement (nonprod, prod) | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Nom du role IAM de deploiement a creer | `string` | n/a | yes |
| <a name="input_trusted_role_arn"></a> [trusted\_role\_arn](#input\_trusted\_role\_arn) | ARN du role source (dans le compte Shared) autorise a endosser ce role | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN du role de deploiement cree |
<!-- END_TF_DOCS -->