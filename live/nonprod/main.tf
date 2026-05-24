# Lecture de l'état du compte shared-services pour récupérer les ARNs KMS et noms de buckets
data "terraform_remote_state" "shared" {
  backend = "local"

  config = {
    path = var.shared_services_state_path
  }
}

# --- 1. Module Réseau (VPC, sous-réseaux, NAT, Route53 privé) ---
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

# --- 2. Module Base de Données RDS (PostgreSQL) ---
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

  admin_roles = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OrganizationAccountAccessRole",
    data.terraform_remote_state.shared.outputs.github_actions_nonprod_role_arn
  ]
  project_name = var.project_name
}

# --- 4. Module DNS et Ingress (Route53 public + ACM + WAF) ---
module "dns_ingress" {
  source = "../../modules/dns-ingress"

  environment               = var.environment
  domain_name               = var.domain_name
  create_public_zone        = true
  enable_extended_waf_rules = false
  project_name              = var.project_name
}

# --- 5. Module Gestion des Secrets (CSI Driver + IRSA) ---
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

# --- 6. Module Observabilité (Prometheus Stack + Grafana + Fluent Bit) ---
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

  depends_on   = [module.eks_cluster, module.aws_load_balancer_controller]
  project_name = var.project_name
}

# --- 7. Delegation Route53 automatique de nonprod.rhorizon.xyz dans la zone parente (compte shared) ---
data "aws_route53_zone" "parent" {
  provider = aws.shared
  name     = "rhorizon.xyz"
}

resource "aws_route53_record" "nonprod_delegation" {
  provider = aws.shared
  zone_id  = data.aws_route53_zone.parent.zone_id
  name     = var.domain_name
  type     = "NS"
  ttl      = 300
  records  = module.dns_ingress.route53_zone_name_servers
}

# --- 9. Module Bastion SSM (Accès RDS sécurisé) ---
module "ssm_bastion" {
  source = "../../modules/ssm-bastion"

  environment           = var.environment
  vpc_id                = module.network.vpc_id
  subnet_id             = module.network.private_subnet_ids[0]
  rds_security_group_id = module.network.rds_security_group_id
  project_name          = var.project_name
}

# --- 10. Rôle IAM et Politique pour IRSA (Accès S3 du Backend) ---
resource "aws_iam_policy" "backend_s3_access" {
  name        = "${var.environment}-backend-s3-policy"
  description = "Politique autorisant le backend EKS a acceder au bucket S3 d assets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          data.terraform_remote_state.shared.outputs.bucket_assets_arn,
          "${data.terraform_remote_state.shared.outputs.bucket_assets_arn}/*"
        ]
      },
      {
        Sid    = "KMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = data.terraform_remote_state.shared.outputs.kms_assets_key_arn
      }
    ]
  })
}

resource "aws_iam_role" "backend_s3_role" {
  name = "${var.project_name}-${var.environment}-backend-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks_cluster.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks_cluster.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:${var.project_name}:${var.project_name}-backend-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backend_s3_attach" {
  role       = aws_iam_role.backend_s3_role.name
  policy_arn = aws_iam_policy.backend_s3_access.arn
}

# --- 11. Règle de sécurité pour autoriser le trafic de l'EKS vers RDS ---
resource "aws_security_group_rule" "rds_ingress_from_eks_cluster" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.network.rds_security_group_id
  source_security_group_id = module.eks_cluster.cluster_security_group_id
  description              = "Autoriser le trafic PostgreSQL depuis EKS (Cluster SG)"
}

# --- 12. Identité appelante ---
data "aws_caller_identity" "current" {}
