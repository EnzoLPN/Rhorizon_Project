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
| [aws_iam_policy.github_actions_nonprod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.github_actions_prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.github_actions_nonprod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.github_actions_prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.github_nonprod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.github_prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `any` | n/a | yes |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | n/a | `any` | n/a | yes |
| <a name="input_github_project"></a> [github\_project](#input\_github\_project) | n/a | `any` | n/a | yes |
| <a name="input_nonprod_account_id"></a> [nonprod\_account\_id](#input\_nonprod\_account\_id) | n/a | `any` | n/a | yes |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | n/a | `any` | n/a | yes |
| <a name="input_prod_account_id"></a> [prod\_account\_id](#input\_prod\_account\_id) | n/a | `any` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_actions_nonprod_role_arn"></a> [github\_actions\_nonprod\_role\_arn](#output\_github\_actions\_nonprod\_role\_arn) | n/a |
| <a name="output_github_actions_prod_role_arn"></a> [github\_actions\_prod\_role\_arn](#output\_github\_actions\_prod\_role\_arn) | n/a |
<!-- END_TF_DOCS -->