# --- Installation du Secrets Store CSI Driver (Helm) ---
resource "helm_release" "csi_driver" {
  name       = "secrets-store-csi-driver"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  namespace  = "kube-system"
  version    = "1.6.0"

  values = [
    yamlencode({
      syncSecret = {
        enabled = true
      }
      enableSecretRotation = true
      rotationPollInterval = "2m"
    })
  ]
}

# --- Installation du Provider AWS (ASCP) ---
resource "helm_release" "aws_provider" {
  name       = "secrets-store-csi-driver-provider-aws"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  namespace  = "kube-system"
  version    = "0.3.11"

  depends_on = [helm_release.csi_driver]
}
