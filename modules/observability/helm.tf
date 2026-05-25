resource "helm_release" "prometheus" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "85.2.1"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name

  values = [
    templatefile("${path.module}/templates/prometheus-values.yaml.tpl", {
      PROMETHEUS_STORAGE_SPEC    = var.environment == "prod" ? "volumeClaimTemplate:\n      spec:\n        storageClassName: \"gp3-encrypted\"\n        accessModes: [\"ReadWriteOnce\"]\n        resources:\n          requests:\n            storage: \"20Gi\"" : "emptyDir:\n      medium: \"\""
      PROMETHEUS_REQ_CPU         = var.environment == "prod" ? "500m" : "100m"
      PROMETHEUS_REQ_MEM         = var.environment == "prod" ? "2Gi" : "256Mi"
      PROMETHEUS_LIM_CPU         = var.environment == "prod" ? "1000m" : "500m"
      PROMETHEUS_LIM_MEM         = var.environment == "prod" ? "4Gi" : "512Mi"
      GRAFANA_INGRESS_ENABLED    = var.grafana_ingress_enabled
      ACM_CERTIFICATE_ARN        = var.acm_certificate_arn
      WAF_WEB_ACL_ARN            = var.waf_web_acl_arn
      GRAFANA_PERSISTENCE_ENABLED = var.environment == "prod" ? true : false
      GRAFANA_REQ_CPU            = var.environment == "prod" ? "100m" : "50m"
      GRAFANA_REQ_MEM            = var.environment == "prod" ? "512Mi" : "256Mi"
      GRAFANA_LIM_CPU            = var.environment == "prod" ? "500m" : "200m"
      GRAFANA_LIM_MEM            = var.environment == "prod" ? "1Gi" : "512Mi"
      ALERTMANAGER_REQ_CPU       = var.environment == "prod" ? "100m" : "50m"
      ALERTMANAGER_REQ_MEM       = var.environment == "prod" ? "128Mi" : "64Mi"
      ALERTMANAGER_LIM_CPU       = var.environment == "prod" ? "200m" : "100m"
      ALERTMANAGER_LIM_MEM       = var.environment == "prod" ? "256Mi" : "128Mi"
    })
  ]
}

resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = "0.57.5"
  namespace  = kubernetes_namespace_v1.logging.metadata[0].name

  values = [
    templatefile("${path.module}/templates/fluent-bit-values.yaml.tpl", {
      FLUENT_BIT_ROLE_ARN = aws_iam_role.fluent_bit.arn
      AWS_REGION          = var.aws_region
      ENVIRONMENT         = var.environment
      LOGS_BUCKET_NAME    = var.logs_bucket_name
    })
  ]
}
