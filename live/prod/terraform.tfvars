project_name       = "rhorizon"
environment        = "prod"
aws_profile        = "aws-prod"
aws_region         = "eu-west-1"

# Réseau
vpc_cidr            = "10.20.0.0/16"
az_count            = 3
subnet_cidr_mask    = 23
nat_strategy        = "per_az"
private_domain_name = "pr.rhorizon.local"

# DNS
domain_name = "rhorizon.xyz"

# EKS
kubernetes_version = "1.32"
eks_instance_types = ["t3.medium"]
eks_desired_size   = 3
eks_min_size       = 3
eks_max_size       = 6

# RDS - Géré automatiquement via AWS Secrets Manager
# shared_services_state_path = "../shared-services/terraform.tfstate"
