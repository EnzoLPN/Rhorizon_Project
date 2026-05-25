# --- Enregistrement DNS Route53 pour Grafana ---

data "kubernetes_ingress_v1" "grafana" {
  count = var.grafana_ingress_enabled ? 1 : 0

  metadata {
    name      = "kube-prometheus-stack-grafana"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }
  depends_on = [helm_release.prometheus]
}

resource "aws_route53_record" "grafana" {
  count = var.create_grafana_dns_record ? 1 : 0

  zone_id = var.route53_zone_id
  name    = var.grafana_domain_name
  type    = "CNAME"
  ttl     = 300
  records = [data.kubernetes_ingress_v1.grafana[0].status[0].load_balancer[0].ingress[0].hostname]
}
