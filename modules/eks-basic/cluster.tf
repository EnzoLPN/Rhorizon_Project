# --- Cluster EKS ---
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-${var.environment}-eks-cluster"
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-cluster"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}
