# 📦 Module Core Network

Ce module pose les fondations réseau (VPC, Subnets publics/privés/data, NAT Gateway, Route53 privé) nécessaires au projet.

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
| [aws_cloudwatch_log_group.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route53_zone.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route_table.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpc_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.alb_egress_to_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.rds_ingress_from_eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.interface](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | Nombre de zones de disponibilite a utiliser | `number` | `2` | no |
| <a name="input_enable_phz"></a> [enable\_phz](#input\_enable\_phz) | Activer ou non la zone DNS privee Route 53 | `bool` | `true` | no |
| <a name="input_enable_vpc_endpoints"></a> [enable\_vpc\_endpoints](#input\_enable\_vpc\_endpoints) | Activer ou non les VPC Endpoints d'interface (PrivateLink) | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l'environnement (ex: nonprod, prod) | `string` | n/a | yes |
| <a name="input_flow_logs_retention_days"></a> [flow\_logs\_retention\_days](#input\_flow\_logs\_retention\_days) | Duree de retention des logs de flux VPC (en jours) | `number` | `14` | no |
| <a name="input_nat_strategy"></a> [nat\_strategy](#input\_nat\_strategy) | Strategie NAT Gateway : 'single' (une seule NAT partagee) ou 'per\_az' (une NAT dediee par zone) | `string` | `"single"` | no |
| <a name="input_private_domain_name"></a> [private\_domain\_name](#input\_private\_domain\_name) | Nom de domaine de la zone DNS privee | `string` | `"rhorizon.local"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |
| <a name="input_subnet_cidr_mask"></a> [subnet\_cidr\_mask](#input\_subnet\_cidr\_mask) | Masque de sous-reseau (ex: 24 pour /24, 23 pour /23) | `number` | `24` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | Bloc CIDR pour le VPC | `string` | n/a | yes |
| <a name="input_vpc_endpoints"></a> [vpc\_endpoints](#input\_vpc\_endpoints) | Liste des services AWS pour lesquels creer des VPC Endpoints d'interface | `list(string)` | <pre>[<br/>  "sts",<br/>  "ecr.api",<br/>  "ecr.dkr",<br/>  "kms",<br/>  "secretsmanager",<br/>  "logs"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_security_group_id"></a> [alb\_security\_group\_id](#output\_alb\_security\_group\_id) | ID du Security Group de l'ALB public |
| <a name="output_app_security_group_id"></a> [app\_security\_group\_id](#output\_app\_security\_group\_id) | ID du Security Group du tier applicatif (EKS) |
| <a name="output_data_subnet_ids"></a> [data\_subnet\_ids](#output\_data\_subnet\_ids) | Liste des IDs des sous-reseaux de donnees (RDS) |
| <a name="output_private_hosted_zone_id"></a> [private\_hosted\_zone\_id](#output\_private\_hosted\_zone\_id) | ID de la zone DNS privee Route 53 |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | Liste des IDs des sous-reseaux privatifs (applicatifs) |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Liste des IDs des sous-reseaux publics |
| <a name="output_rds_security_group_id"></a> [rds\_security\_group\_id](#output\_rds\_security\_group\_id) | ID du Security Group de la base de donnees RDS |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | Bloc CIDR du VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID du VPC |
