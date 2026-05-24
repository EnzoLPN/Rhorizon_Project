#!/usr/bin/env bash
set -euo pipefail

# install-monitoring.sh
# Usage: ./install-monitoring.sh [nonprod|prod]

ENVIRONMENT="${1:-}"
if [[ "$ENVIRONMENT" != "nonprod" && "$ENVIRONMENT" != "prod" ]]; then
  echo "❌ Error: Environment argument must be 'nonprod' or 'prod'."
  echo "Usage: $0 [nonprod|prod]"
  exit 1
fi

# Go to script directory
cd "$(dirname "${BASH_SOURCE[0]}")"

echo "=== 1. Checking required environment variables for $ENVIRONMENT ==="

REQUIRED_VARS=(
  "AWS_REGION"
  "GRAFANA_DOMAIN_NAME"
  "ACM_CERTIFICATE_ARN"
  "WAF_WEB_ACL_ARN"
  "LOGS_BUCKET_NAME"
  "FLUENT_BIT_ROLE_ARN"
)

for VAR in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!VAR:-}" ]; then
    echo "❌ Error: Environment variable $VAR is not set."
    exit 1
  fi
done

echo "All required environment variables are set."

# Set Helm release parameters based on Environment
echo -e "\n=== 2. Setting parameters for environment: $ENVIRONMENT ==="
export ENVIRONMENT

if [ "$ENVIRONMENT" == "prod" ]; then
  export PROMETHEUS_STORAGE_SPEC="volumeClaimTemplate:
        spec:
          storageClassName: \"gp3-encrypted\"
          accessModes: [\"ReadWriteOnce\"]
          resources:
            requests:
              storage: \"20Gi\""
  export PROMETHEUS_REQ_CPU="500m"
  export PROMETHEUS_REQ_MEM="2Gi"
  export PROMETHEUS_LIM_CPU="1000m"
  export PROMETHEUS_LIM_MEM="4Gi"

  export GRAFANA_PERSISTENCE_ENABLED="true"
  export GRAFANA_REQ_CPU="100m"
  export GRAFANA_REQ_MEM="512Mi"
  export GRAFANA_LIM_CPU="500m"
  export GRAFANA_LIM_MEM="1Gi"

  export ALERTMANAGER_REQ_CPU="100m"
  export ALERTMANAGER_REQ_MEM="128Mi"
  export ALERTMANAGER_LIM_CPU="200m"
  export ALERTMANAGER_LIM_MEM="256Mi"
  export GRAFANA_INGRESS_ENABLED="true"
else
  export PROMETHEUS_STORAGE_SPEC="emptyDir:
        medium: \"\""
  export PROMETHEUS_REQ_CPU="100m"
  export PROMETHEUS_REQ_MEM="256Mi"
  export PROMETHEUS_LIM_CPU="500m"
  export PROMETHEUS_LIM_MEM="512Mi"

  export GRAFANA_PERSISTENCE_ENABLED="false"
  export GRAFANA_REQ_CPU="50m"
  export GRAFANA_REQ_MEM="256Mi"
  export GRAFANA_LIM_CPU="200m"
  export GRAFANA_LIM_MEM="512Mi"

  export ALERTMANAGER_REQ_CPU="50m"
  export ALERTMANAGER_REQ_MEM="64Mi"
  export ALERTMANAGER_LIM_CPU="100m"
  export ALERTMANAGER_LIM_MEM="128Mi"
  export GRAFANA_INGRESS_ENABLED="true"
fi

echo -e "\n=== 3. Creating generated directory and templates ==="
GENERATED_DIR="generated"
mkdir -p "$GENERATED_DIR"

# Interpolate configuration values using envsubst
envsubst < prometheus-values.yaml.tmpl > "$GENERATED_DIR/prometheus-values.yaml"
envsubst < fluent-bit-values.yaml.tmpl > "$GENERATED_DIR/fluent-bit-values.yaml"

echo "Generated Helm values files in: $GENERATED_DIR/"

echo -e "\n=== 4. Updating Helm Repositories ==="
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

echo -e "\n=== 5. Installing / Upgrading kube-prometheus-stack ==="
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --version "85.2.1" \
  -f "$GENERATED_DIR/prometheus-values.yaml"

echo -e "\n=== 6. Installing / Upgrading Fluent Bit ==="
kubectl create namespace logging --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install fluent-bit fluent/fluent-bit \
  --namespace logging \
  --version "0.57.5" \
  -f "$GENERATED_DIR/fluent-bit-values.yaml"

echo -e "\n=== 7. Updating Route 53 DNS record for $GRAFANA_DOMAIN_NAME ==="
ALB_HOSTNAME=""
echo "Waiting for Grafana ALB DNS hostname to be assigned..."
# Poll for up to 5 minutes
for i in {1..60}; do
  ALB_HOSTNAME=$(kubectl get ingress kube-prometheus-stack-grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)
  if [ -n "$ALB_HOSTNAME" ]; then
    break
  fi
  echo -n "."
  sleep 5
done
echo ""

if [ -z "$ALB_HOSTNAME" ]; then
  echo "⚠️ Warning: Grafana ALB DNS Hostname was not assigned within timeout. Please update Route 53 manually later."
else
  echo "ALB DNS Hostname: $ALB_HOSTNAME"

  # Query the Route53 Zone ID dynamically from AWS
  # Note: This assumes the zone for GRAFANA_DOMAIN_NAME exists in the current account
  echo "Querying Route 53 Zone ID for $GRAFANA_DOMAIN_NAME..."
  ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name "$GRAFANA_DOMAIN_NAME" --query "HostedZones[0].Id" --output text | cut -d'/' -f3)

  if [ -z "$ZONE_ID" ] || [ "$ZONE_ID" == "None" ]; then
    echo "❌ Error: Could not find hosted zone for $GRAFANA_DOMAIN_NAME."
  else
    echo "Hosted Zone ID: $ZONE_ID"
    echo "Updating Route 53 Alias record..."
    ALB_HOSTNAME_DOT="${ALB_HOSTNAME}."
    aws route53 change-resource-record-sets --hosted-zone-id "$ZONE_ID" --change-batch "{
      \"Comment\": \"Update $GRAFANA_DOMAIN_NAME to point to Grafana ALB\",
      \"Changes\": [
        {
          \"Action\": \"UPSERT\",
          \"ResourceRecordSet\": {
            \"Name\": \"${GRAFANA_DOMAIN_NAME}.\",
            \"Type\": \"A\",
            \"AliasTarget\": {
              \"HostedZoneId\": \"Z32O12XQLNTSW2\",
              \"DNSName\": \"$ALB_HOSTNAME_DOT\",
              \"EvaluateTargetHealth\": false
            }
          }
        }
      ]
    }"
  fi
fi

echo -e "\n🚀 === MONITORING INSTALLATION COMPLETED SUCCESSFULLY ==="
echo "Grafana URL: https://$GRAFANA_DOMAIN_NAME"
