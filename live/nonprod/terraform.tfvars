project_name       = "rhorizon"
environment        = "nonprod"
aws_profile        = "aws-nonprod"
aws_region         = "eu-west-1"

# Réseau
vpc_cidr            = "10.10.0.0/16"
az_count            = 2
subnet_cidr_mask    = 24
nat_strategy        = "single"
private_domain_name = "np.rhorizon.local"

# DNS
domain_name = "nonprod.rhorizon.xyz"

# EKS
kubernetes_version = "1.32"
eks_instance_types = ["t3.medium"]
eks_desired_size   = 2
eks_min_size       = 2
eks_max_size       = 2

# RDS - Géré automatiquement via AWS Secrets Manager
# shared_services_state_path = "../shared-services/terraform.tfstate"
