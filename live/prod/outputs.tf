output "vpc_id" {
  value       = module.network.vpc_id
  description = "ID du VPC prod"
}

output "cluster_name" {
  value       = module.eks_cluster.cluster_name
  description = "Nom du cluster EKS prod"
}

output "cluster_endpoint" {
  value       = module.eks_cluster.cluster_endpoint
  description = "Endpoint API du cluster EKS prod"
}

output "rds_endpoint" {
  value       = module.rds.db_instance_endpoint
  description = "Endpoint de la base de données RDS prod"
  sensitive   = true
}

output "route53_zone_id" {
  value       = module.dns_ingress.route53_zone_id
  description = "ID de la zone Route53 publique prod"
}

output "acm_certificate_arn" {
  value       = module.dns_ingress.acm_certificate_arn
  description = "ARN du certificat ACM prod"
}

# --- Outputs Bastion SSM ---
output "ssm_bastion_instance_id" {
  value       = module.ssm_bastion.instance_id
  description = "ID de l'instance du Bastion SSM"
}

output "ssm_bastion_tunnel_command" {
  value       = "aws ssm start-session --target ${module.ssm_bastion.instance_id} --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{\"host\":[\"${module.rds.db_instance_address}\"],\"portNumber\":[\"5432\"],\"localPortNumber\":[\"5432\"]}' --profile ${var.aws_profile} --region ${var.aws_region}"
  description = "Commande pour ouvrir un tunnel local sécurisé vers la base RDS"
}

output "waf_web_acl_arn" {
  value       = module.dns_ingress.waf_web_acl_arn
  description = "ARN du Web ACL WAFv2 regional pour l'Ingress"
}

output "fluent_bit_role_arn" {
  value       = module.observability.fluent_bit_role_arn
  description = "ARN du role IAM attribue a Fluent Bit (IRSA)"
}

output "app_role_arn" {
  value       = module.eks_cluster.irsa_role_arns["app"]
  description = "ARN du role IAM attribue à l'application unifiée pour l'accès S3/KMS (IRSA)"
}


