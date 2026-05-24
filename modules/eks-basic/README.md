# Module : Cluster Kubernetes (EKS Basic)

Ce module déploie un cluster Amazon EKS hautement disponible et sécurisé, servant de socle à l'exécution des conteneurs applicatifs.

## 🛡️ Points clés de Sécurité (ASD)
*   **Accès Privé à l'API** : Le cluster est déployé dans des sous-réseaux privés. L'accès à l'API peut être restreint aux réseaux autorisés.
*   **IAM Roles for Service Accounts (IRSA)** : Configuration d'un fournisseur OIDC permettant d'associer des rôles IAM précis à chaque Pod Kubernetes (principe du moindre privilège).
*   **EKS Access Entries** : Utilisation du nouveau mode de gestion des accès Kubernetes natif via IAM, remplaçant la ConfigMap `aws-auth` pour une meilleure sécurité et auditabilité.
*   **Nœuds Gérés Chiffrés** : Les volumes EBS des nœuds de calcul sont chiffrés par défaut via KMS.
*   **Add-ons de Sécurité** : Installation automatique des composants critiques (VPC CNI, CoreDNS, Kube-proxy) avec gestion des versions.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_access_entry.admins](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_policy_association.admins](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource |
| [aws_eks_addon.coredns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.kube_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.vpc_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_openid_connect_provider.oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cluster_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.worker_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.ebs_csi_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [tls_certificate.eks](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_roles"></a> [admin\_roles](#input\_admin\_roles) | Liste des ARN de rôles IAM à qui donner les droits cluster-admin via EKS Access Entries | `list(string)` | `[]` | no |
| <a name="input_desired_size"></a> [desired\_size](#input\_desired\_size) | Nombre souhaite de noeuds dans le groupe de noeuds | `number` | `2` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l'environnement (ex: nonprod, prod) | `string` | n/a | yes |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | Liste des types d'instances pour les noeuds EKS | `list(string)` | <pre>[<br/>  "t3.medium"<br/>]</pre> | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Version de Kubernetes pour le cluster EKS | `string` | `"1.31"` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Nombre maximal de noeuds dans le groupe | `number` | `3` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Nombre minimal de noeuds dans le groupe | `number` | `1` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (ex: rhorizon) | `string` | `"rhorizon"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Liste des sous-reseaux prives (applicatifs) pour EKS | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID du VPC dans lequel déployer le cluster EKS | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Donnees de certificat necessaires pour s'authentifier aupres du cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint d'API du cluster Kubernetes |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | Identifiant unique du cluster EKS |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Nom du cluster EKS |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | ID du groupe de securite cree automatiquement par EKS pour le cluster |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | ARN du fournisseur OIDC EKS (pour les configurations IRSA) |
| <a name="output_oidc_provider_url"></a> [oidc\_provider\_url](#output\_oidc\_provider\_url) | URL de l'Identity Provider OIDC associe au cluster |
