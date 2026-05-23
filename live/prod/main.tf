# Lecture de l'état du compte shared-services
data "terraform_remote_state" "shared" {
  backend = "local"

  config = {
    path = var.shared_services_state_path
  }
}

# --- 1. Module Réseau ---
module "network" {
  source = "../../modules/core-network"

  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  az_count                 = var.az_count
  subnet_cidr_mask         = var.subnet_cidr_mask
  nat_strategy             = var.nat_strategy
  flow_logs_retention_days = 90
  enable_phz               = true
  private_domain_name      = var.private_domain_name
  enable_vpc_endpoints     = true
}

# --- 2. Module Base de Données RDS ---
module "rds" {
  source = "../../modules/rds-database"

  environment           = var.environment
  subnet_ids            = module.network.data_subnet_ids
  rds_security_group_id = module.network.rds_security_group_id

  instance_class        = "db.t4g.medium"
  allocated_storage     = 50
  max_allocated_storage = 200

  db_name        = "rhorizon_prod"
  admin_username = "dbadmin"
  admin_password = var.db_admin_password

  multi_az                = true
  backup_retention_period = 30
  deletion_protection     = true
  skip_final_snapshot     = false
  storage_encrypted       = true
  kms_key_arn             = data.terraform_remote_state.shared.outputs.kms_backups_key_arn
}

# --- 3. Module Cluster EKS ---
module "eks_cluster" {
  source = "../../modules/eks-basic"

  environment        = var.environment
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.private_subnet_ids
  kubernetes_version = var.kubernetes_version
  instance_types     = var.eks_instance_types
  desired_size       = var.eks_desired_size
  min_size           = var.eks_min_size
  max_size           = var.eks_max_size
}

# --- 4. Module DNS et Ingress ---
module "dns_ingress" {
  source = "../../modules/dns-ingress"

  environment               = var.environment
  domain_name               = var.domain_name
  create_public_zone        = true
  enable_extended_waf_rules = true
}

# --- 5. Module Gestion des Secrets ---
module "secrets_management" {
  source = "../../modules/secrets-management"

  environment       = var.environment
  oidc_provider_url = module.eks_cluster.oidc_provider_url
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn
  kms_key_arn       = data.terraform_remote_state.shared.outputs.kms_assets_key_arn

  depends_on = [module.eks_cluster]
}

# --- 5b. Module AWS Load Balancer Controller ---
module "aws_load_balancer_controller" {
  source = "../../modules/aws-load-balancer-controller"

  environment       = var.environment
  cluster_name      = module.eks_cluster.cluster_name
  oidc_provider_url = module.eks_cluster.oidc_provider_url
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn
  vpc_id            = module.network.vpc_id
  aws_region        = var.aws_region

  depends_on = [module.eks_cluster]
}

# --- 6. Module Observabilité ---
module "observability" {
  source = "../../modules/observability"

  environment       = var.environment
  oidc_provider_url = module.eks_cluster.oidc_provider_url
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn
  logs_bucket_name  = data.terraform_remote_state.shared.outputs.bucket_logs_id
  kms_logs_key_arn  = data.terraform_remote_state.shared.outputs.kms_logs_key_arn

  grafana_ingress_enabled = true
  grafana_domain_name     = "grafana.${var.domain_name}"
  acm_certificate_arn     = module.dns_ingress.acm_certificate_arn
  waf_web_acl_arn         = module.dns_ingress.waf_web_acl_arn

  depends_on = [module.eks_cluster, module.aws_load_balancer_controller]
}

# --- 7. Delegation Route53 automatique de rhorizon.xyz dans la zone parente (compte shared) ---
data "aws_route53_zone" "parent" {
  provider = aws.shared
  name     = "rhorizon.xyz"
}

resource "aws_route53_record" "prod_delegation" {
  provider = aws.shared
  zone_id  = data.aws_route53_zone.parent.zone_id
  name     = var.domain_name
  type     = "NS"
  ttl      = 300
  records  = module.dns_ingress.route53_zone_name_servers
}

# --- 8. Enregistrement DNS Route53 pour Grafana ---
data "kubernetes_ingress_v1" "grafana" {
  metadata {
    name      = "kube-prometheus-stack-grafana"
    namespace = "monitoring"
  }
  depends_on = [module.observability]
}

resource "aws_route53_record" "grafana" {
  zone_id = module.dns_ingress.route53_zone_id
  name    = "grafana.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [data.kubernetes_ingress_v1.grafana.status[0].load_balancer[0].ingress[0].hostname]
}

# --- 9. Module Bastion SSM (Accès RDS sécurisé) ---
module "ssm_bastion" {
  source = "../../modules/ssm-bastion"

  environment           = var.environment
  vpc_id                = module.network.vpc_id
  subnet_id             = module.network.private_subnet_ids[0]
  rds_security_group_id = module.network.rds_security_group_id
}



