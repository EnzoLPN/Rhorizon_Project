# --- StorageClass GP3 Chiffree ---
resource "kubernetes_storage_class_v1" "gp3_encrypted" {
  count = var.environment == "prod" ? 1 : 0
  metadata {
    name = "gp3-encrypted"
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    type      = "gp3"
    encrypted = "true"
    kmsKeyId  = var.kms_logs_key_arn
  }
}
