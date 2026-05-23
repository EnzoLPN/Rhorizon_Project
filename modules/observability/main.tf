# --- Namespaces Kubernetes pour l'Observabilite ---
resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_namespace_v1" "logging" {
  metadata {
    name = "logging"
  }
}

# --- Role IAM (IRSA) pour Fluent Bit (Acces CloudWatch Logs S3) ---
resource "aws_iam_role" "fluent_bit" {
  name = "${var.environment}-eks-fluent-bit-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:logging:fluent-bit"
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# Politique IAM specifique et restreinte pour Fluent Bit (Securite ANSSI)
resource "aws_iam_policy" "fluent_bit" {
  name        = "${var.environment}-eks-fluent-bit-policy"
  description = "Politique autorisant Fluent Bit a ecrire ses logs dans CloudWatch et S3 pour l environnement ${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/eks/rhzorion/${var.environment}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${var.logs_bucket_name}/eks/${var.environment}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::${var.logs_bucket_name}"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt",
          "kms:Encrypt"
        ]
        Resource = var.kms_logs_key_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fluent_bit" {
  role       = aws_iam_role.fluent_bit.name
  policy_arn = aws_iam_policy.fluent_bit.arn
}

# --- StorageClass GP3 Chiffree (Uniquement en Production pour la persistance) ---
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

# --- Deploiement de kube-prometheus-stack (Prometheus \u0026 Grafana) ---
resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  version    = "85.2.1"

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          # Si prod, on active la persistance EBS gp3 chiffree
          # Si nonprod, on utilise un stockage temporaire pour reduire le budget
          storageSpec = merge(
            var.environment == "prod" ? {
              volumeClaimTemplate = {
                spec = {
                  storageClassName = "gp3-encrypted"
                  accessModes      = ["ReadWriteOnce"]
                  resources = {
                    requests = {
                      storage = "20Gi"
                    }
                  }
                }
              }
            } : {},
            var.environment != "prod" ? {
              emptyDir = {
                medium = ""
              }
            } : {}
          )

          # Optimisation des ressources demandees en Non-Prod vs Prod
          resources = var.environment == "prod" ? {
            requests = {
              cpu    = "500m"
              memory = "2Gi"
            }
            limits = {
              cpu    = "1000m"
              memory = "4Gi"
            }
          } : {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }

      grafana = {
        # Exposition de Grafana via Ingress (ALB / ACM / WAFv2)
        ingress = {
          enabled          = var.grafana_ingress_enabled
          ingressClassName = "alb"
          annotations = merge(
            {
              "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
              "alb.ingress.kubernetes.io/target-type"      = "ip"
              "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
              "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
              "alb.ingress.kubernetes.io/healthcheck-path" = "/api/health"
            },
            var.acm_certificate_arn != "" ? {
              "alb.ingress.kubernetes.io/certificate-arn" = var.acm_certificate_arn
            } : {},
            var.waf_web_acl_arn != "" ? {
              "alb.ingress.kubernetes.io/waf-acl-arn" = var.waf_web_acl_arn
            } : {}
          )
          hosts = var.grafana_domain_name != "" ? [var.grafana_domain_name] : []
          path  = "/"
        }

        # Persistance de la configuration et des dashboards
        persistence = {
          enabled          = var.environment == "prod" ? true : false
          storageClassName = "gp3-encrypted"
          size             = "10Gi"
        }

        resources = var.environment == "prod" ? {
          requests = {
            cpu    = "100m"
            memory = "512Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "1Gi"
          }
        } : {
          requests = {
            cpu    = "50m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "512Mi"
          }
        }
      }

      alertmanager = {
        alertmanagerSpec = {
          resources = var.environment == "prod" ? {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          } : {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.monitoring
  ]
}

# --- Deploiement de Fluent Bit (Collecte de logs vers CloudWatch & S3) ---
resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  namespace  = kubernetes_namespace_v1.logging.metadata[0].name
  version    = "0.57.5"

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = "fluent-bit"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.fluent_bit.arn
        }
      }

      config = {
        inputs = <<-EOT
          [INPUT]
              Name            tail
              Tag             kube.*
              Path            /var/log/containers/*.log
              Parser          docker
              DB              /var/log/flb_kube.db
              Mem_Buf_Limit   5MB
              Skip_Long_Lines On
        EOT

        filters = <<-EOT
          [FILTER]
              Name                kubernetes
              Match               kube.*
              Kube_URL            https://kubernetes.default.svc:443
              Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
              Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
              Kube_Tag_Prefix     kube.var.log.containers.
              Merge_Log           On
              Keep_Log            Off
              K8S-Logging.Parser  On
              K8S-Logging.Exclude On
        EOT

        outputs = <<-EOT
          [OUTPUT]
              Name            cloudwatch_logs
              Match           kube.*
              region          ${var.aws_region}
              log_group_name  /eks/rhzorion/${var.environment}/applications
              log_stream_prefix fluent-bit-
              auto_create_group true

          [OUTPUT]
              Name            s3
              Match           kube.*
              bucket          ${var.logs_bucket_name}
              region          ${var.aws_region}
              s3_key_format   /eks/${var.environment}/%Y/%m/%d/%H-%M-%S-$UUID.gz
              store_dir       /tmp/fluent-bit/s3
              upload_timeout  1m
        EOT
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.logging,
    aws_iam_role_policy_attachment.fluent_bit
  ]
}
