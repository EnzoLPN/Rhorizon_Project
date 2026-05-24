# --- EKS Access Entries (Remplacement de aws-auth ConfigMap) ---
resource "aws_eks_access_entry" "admins" {
  for_each          = toset(var.admin_roles)
  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = each.value
  kubernetes_groups = []
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "admins" {
  for_each      = toset(var.admin_roles)
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value

  access_scope {
    type       = "cluster"
  }
}
