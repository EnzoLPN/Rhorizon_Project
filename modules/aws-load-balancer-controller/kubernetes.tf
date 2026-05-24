# --- 3. Service Account Kubernetes ---
resource "kubernetes_service_account_v1" "service_account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.role.arn
    }
  }
}
