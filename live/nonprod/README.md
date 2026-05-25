<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.98 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.17 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.37 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_load_balancer_controller"></a> [aws\_load\_balancer\_controller](#module\_aws\_load\_balancer\_controller) | ../../modules/aws-load-balancer-controller | n/a |
| <a name="module_cicd_deploy_role"></a> [cicd\_deploy\_role](#module\_cicd\_deploy\_role) | ../../modules/cicd-infra/target-role | n/a |
| <a name="module_dns_ingress"></a> [dns\_ingress](#module\_dns\_ingress) | ../../modules/dns-ingress | n/a |
| <a name="module_eks_cluster"></a> [eks\_cluster](#module\_eks\_cluster) | ../../modules/eks-basic | n/a |
| <a name="module_eks_deploy_iam"></a> [eks\_deploy\_iam](#module\_eks\_deploy\_iam) | ../../modules/cicd-target-role | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../../modules/core-network | n/a |
| <a name="module_observability"></a> [observability](#module\_observability) | ../../modules/observability | n/a |
| <a name="module_rds"></a> [rds](#module\_rds) | ../../modules/rds-database | n/a |
| <a name="module_secrets_management"></a> [secrets\_management](#module\_secrets\_management) | ../../modules/secrets-management | n/a |
| <a name="module_ssm_bastion"></a> [ssm\_bastion](#module\_ssm\_bastion) | ../../modules/ssm-bastion | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [terraform_remote_state.shared](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | Profil AWS CLI SSO pour le compte nonprod | `string` | `"aws-nonprod"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Région AWS | `string` | `"eu-west-1"` | no |
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | Nombre de zones de disponibilité | `number` | `2` | no |
| <a name="input_db_admin_password"></a> [db\_admin\_password](#input\_db\_admin\_password) | Mot de passe de l'administrateur de la base de données | `string` | `"RHZorionDevPass2026!"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Nom de domaine public principal | `string` | `"nonprod.rhorizon.xyz"` | no |
| <a name="input_eks_desired_size"></a> [eks\_desired\_size](#input\_eks\_desired\_size) | Nombre de noeuds EKS souhaité | `number` | `1` | no |
| <a name="input_eks_instance_types"></a> [eks\_instance\_types](#input\_eks\_instance\_types) | Types d'instances EC2 pour les noeuds EKS | `list(string)` | <pre>[<br/>  "t3.medium"<br/>]</pre> | no |
| <a name="input_eks_max_size"></a> [eks\_max\_size](#input\_eks\_max\_size) | Nombre maximum de noeuds EKS | `number` | `2` | no |
| <a name="input_eks_min_size"></a> [eks\_min\_size](#input\_eks\_min\_size) | Nombre minimum de noeuds EKS | `number` | `1` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l'environnement | `string` | `"nonprod"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Version de Kubernetes pour EKS | `string` | `"1.32"` | no |
| <a name="input_nat_strategy"></a> [nat\_strategy](#input\_nat\_strategy) | Stratégie NAT (single ou per\_az) | `string` | `"single"` | no |
| <a name="input_private_domain_name"></a> [private\_domain\_name](#input\_private\_domain\_name) | Nom de domaine privé Route53 | `string` | `"np.rhorizon.local"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |
| <a name="input_shared_services_state_path"></a> [shared\_services\_state\_path](#input\_shared\_services\_state\_path) | Chemin vers le fichier tfstate de shared-services | `string` | `"../shared-services/terraform.tfstate"` | no |
| <a name="input_subnet_cidr_mask"></a> [subnet\_cidr\_mask](#input\_subnet\_cidr\_mask) | Masque de sous-réseau | `number` | `24` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block du VPC | `string` | `"10.10.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | ARN du certificat ACM |
| <a name="output_backend_role_arn"></a> [backend\_role\_arn](#output\_backend\_role\_arn) | ARN du role IAM attribue au Backend pour l'accès S3/KMS (IRSA) |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint API du cluster EKS |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Nom du cluster EKS |
| <a name="output_eks_deploy_role_arn"></a> [eks\_deploy\_role\_arn](#output\_eks\_deploy\_role\_arn) | ARN du role de deploiement local a ce compte |
| <a name="output_fluent_bit_role_arn"></a> [fluent\_bit\_role\_arn](#output\_fluent\_bit\_role\_arn) | ARN du role IAM attribue a Fluent Bit (IRSA) |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | ARN du provider OIDC EKS |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | IDDs des sous-réseaux privés |
| <a name="output_rds_endpoint"></a> [rds\_endpoint](#output\_rds\_endpoint) | Endpoint de la base de données RDS |
| <a name="output_route53_zone_id"></a> [route53\_zone\_id](#output\_route53\_zone\_id) | ID de la zone Route53 publique |
| <a name="output_ssm_bastion_instance_id"></a> [ssm\_bastion\_instance\_id](#output\_ssm\_bastion\_instance\_id) | ID de l'instance du Bastion SSM |
| <a name="output_ssm_bastion_tunnel_command"></a> [ssm\_bastion\_tunnel\_command](#output\_ssm\_bastion\_tunnel\_command) | Commande pour ouvrir un tunnel local sécurisé vers la base RDS |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID du VPC nonprod |
| <a name="output_waf_web_acl_arn"></a> [waf\_web\_acl\_arn](#output\_waf\_web\_acl\_arn) | ARN du Web ACL WAFv2 régional pour l'Ingress |
<!-- END_TF_DOCS -->