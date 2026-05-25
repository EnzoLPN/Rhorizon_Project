# Lecture de l'état du compte shared-services
data "terraform_remote_state" "shared" {
  backend = "local"
  config = {
    path = var.shared_services_state_path
  }
}

# --- 0. IAM de Déploiement ---
module "cicd_deploy_role" {
  source = "../../modules/cicd-infra/target-role"

  role_name        = "nonprod-eks-deploy-role"
  trusted_role_arn = data.terraform_remote_state.shared.outputs.github_actions_nonprod_role_arn
  environment      = var.environment
  project_name     = var.project_name
}

# --- 1. Module Réseau ---
module "network" {
  source = "../../modules/core-network"

  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  az_count                 = var.az_count
  subnet_cidr_mask         = var.subnet_cidr_mask
  nat_strategy             = var.nat_strategy
  flow_logs_retention_days = 14
  enable_phz               = true
  private_domain_name      = var.private_domain_name
  enable_vpc_endpoints     = false
  project_name             = var.project_name
}

# --- 2. Module Base de Données RDS ---
module "rds" {
  source = "../../modules/rds-database"

  environment           = var.environment
  subnet_ids            = module.network.data_subnet_ids
  rds_security_group_id = module.network.rds_security_group_id

  instance_class        = "db.t4g.micro"
  allocated_storage     = 20
  max_allocated_storage = 50

  db_name        = "${var.project_name}_dev"
  admin_username = "dbadmin"
  admin_password = var.db_admin_password

  multi_az                = false
  backup_retention_period = 1
  deletion_protection     = false
  skip_final_snapshot     = true
  storage_encrypted       = true
  project_name            = var.project_name
  
  # Autoriser le trafic depuis le cluster EKS
  create_external_ingress_rule = true
  allowed_security_group_id    = module.eks_cluster.cluster_security_group_id
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

  admin_roles = {
    organization_admin = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OrganizationAccountAccessRole"
    github_actions     = data.terraform_remote_state.shared.outputs.github_actions_nonprod_role_arn
    eks_deploy         = module.cicd_deploy_role.role_arn
  }
  project_name = var.project_name

  # Configuration des rôles IRSA pour les workloads
  irsa_roles = {
    app = {
      role_name       = "${var.project_name}-${var.environment}-app-s3-role"
      service_account = "${var.project_name}-app-sa"
      namespace       = var.project_name
      policy_json     = jsonencode({
        Version = "2012-10-17"
        Statement = [
          { Sid = "S3Access", Effect = "Allow", Action = ["s3:*"], Resource = [data.terraform_remote_state.shared.outputs.bucket_assets_arn, "${data.terraform_remote_state.shared.outputs.bucket_assets_arn}/*"] },
          { Sid = "KMSAccess", Effect = "Allow", Action = ["kms:Decrypt", "kms:GenerateDataKey"], Resource = data.terraform_remote_state.shared.outputs.kms_assets_key_arn },
          { Sid = "RDSIAMAuth", Effect = "Allow", Action = "rds-db:connect", Resource = "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:*/dbadmin" }
        ]
      })
    }
  }
}

# --- 4. Module DNS et Ingress ---
module "dns_ingress" {
  source = "../../modules/dns-ingress"

  providers = {
    aws.shared = aws.shared
  }

  environment               = var.environment
  domain_name               = var.domain_name
  create_public_zone        = true
  enable_extended_waf_rules = false
  project_name              = var.project_name
  parent_zone_name          = "rhorizon.xyz"
}

# --- 5. Module Gestion des Secrets ---
module "secrets_management" {
  source = "../../modules/secrets-management"

  environment       = var.environment
  oidc_provider_url = module.eks_cluster.oidc_provider_url
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn
  kms_key_arn       = data.terraform_remote_state.shared.outputs.kms_assets_key_arn

  depends_on   = [module.eks_cluster]
  project_name = var.project_name
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

  depends_on   = [module.eks_cluster]
  project_name = var.project_name
}

# --- 6. Module Observabilité ---
module "observability" {
  source = "../../modules/observability"

  environment       = var.environment
  oidc_provider_url = module.eks_cluster.oidc_provider_url
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn
  logs_bucket_name  = data.terraform_remote_state.shared.outputs.bucket_logs_id
  kms_logs_key_arn  = data.terraform_remote_state.shared.outputs.kms_logs_key_arn

  grafana_ingress_enabled   = true
  create_grafana_dns_record = true
  grafana_domain_name       = "grafana.${var.domain_name}"
  acm_certificate_arn       = module.dns_ingress.acm_certificate_arn
  waf_web_acl_arn           = module.dns_ingress.waf_web_acl_arn
  route53_zone_id           = module.dns_ingress.route53_zone_id

  depends_on   = [module.eks_cluster, module.aws_load_balancer_controller]
  project_name = var.project_name
}

# --- 9. Module Bastion SSM ---
module "ssm_bastion" {
  source = "../../modules/ssm-bastion"

  environment           = var.environment
  vpc_id                = module.network.vpc_id
  subnet_id             = module.network.private_subnet_ids[0]
  rds_security_group_id = module.network.rds_security_group_id
  project_name          = var.project_name
}

# --- 10. Identité appelante ---
data "aws_caller_identity" "current" {}
