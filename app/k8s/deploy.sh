#!/usr/bin/env bash
set -euo pipefail

# Unified deployment script for ASD project
# Usage: ./deploy.sh

# Go to script directory
cd "$(dirname "${BASH_SOURCE[0]}")"

echo "=== 1. Checking required environment variables ==="

REQUIRED_VARS=(
  "PROJECT_NAME"
  "IMAGE_TAG"
  "ECR_REGISTRY"
  "ECR_REPOSITORY"
  "AWS_REGION"
  "ACM_CERT_ARN"
  "WAF_ACL_ARN"
  "DOMAIN_NAME"
  "DB_HOST"
  "DB_NAME"
  "DB_USER"
  "DB_PASSWORD_BASE64"
  "S3_BUCKET_NAME"
  "APP_ROLE_ARN"
)

for VAR in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!VAR:-}" ]; then
    echo "❌ Error: Environment variable $VAR is not set."
    exit 1
  fi
done

echo "All required environment variables are set."

echo -e "\n=== 2. Creating generated directory ==="
GENERATED_DIR="generated"
mkdir -p "$GENERATED_DIR"

echo -e "\n=== 3. Interpolating templates using envsubst ==="
envsubst < templates/namespace.yaml.tmpl > "$GENERATED_DIR/namespace.yaml"
envsubst < templates/network-policy.yaml.tmpl > "$GENERATED_DIR/network-policy.yaml"
envsubst < templates/app.yaml.tmpl > "$GENERATED_DIR/app.yaml"
envsubst < templates/ingress.yaml.tmpl > "$GENERATED_DIR/ingress.yaml"

echo "Generated interpolated manifests in $GENERATED_DIR/"

echo -e "\n=== 4. Applying Kubernetes Manifests ==="
kubectl apply -f "$GENERATED_DIR/namespace.yaml"
kubectl apply -f "$GENERATED_DIR/network-policy.yaml"
kubectl apply -f "$GENERATED_DIR/app.yaml"
kubectl apply -f "$GENERATED_DIR/ingress.yaml"

echo -e "\n=== 5. Waiting for Deployment to roll out ==="
kubectl rollout status deployment/${PROJECT_NAME}-app -n ${PROJECT_NAME} --timeout=180s

echo -e "\n=== 6. Updating Route 53 DNS record for $DOMAIN_NAME ==="
ALB_HOSTNAME=""
echo "Waiting for ALB DNS hostname to be assigned..."
for i in {1..36}; do
  ALB_HOSTNAME=$(kubectl get ingress ${PROJECT_NAME}-ingress -n ${PROJECT_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)
  if [ -n "$ALB_HOSTNAME" ]; then
    break
  fi
  sleep 5
done

if [ -z "$ALB_HOSTNAME" ]; then
  echo "❌ Error: ALB DNS Hostname was not assigned within timeout."
  exit 1
fi
echo "ALB DNS Hostname: $ALB_HOSTNAME"

ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name "$DOMAIN_NAME" --query "HostedZones[0].Id" --output text | cut -d'/' -f3)

if [ -z "$ZONE_ID" ] || [ "$ZONE_ID" == "None" ]; then
  echo "❌ Error: Could not find hosted zone for $DOMAIN_NAME."
  exit 1
fi

aws route53 change-resource-record-sets --hosted-zone-id "$ZONE_ID" --change-batch "{
  \"Comment\": \"Update $DOMAIN_NAME to point to EKS ALB\",
  \"Changes\": [
    {
      \"Action\": \"UPSERT\",
      \"ResourceRecordSet\": {
        \"Name\": \"${DOMAIN_NAME}.\",
        \"Type\": \"A\",
        \"AliasTarget\": {
          \"HostedZoneId\": \"Z32O12XQLNTSW2\",
          \"DNSName\": \"${ALB_HOSTNAME}.\",
          \"EvaluateTargetHealth\": false
        }
      }
    }
  ]
}"

echo -e "\n🚀 === DEPLOYMENT COMPLETED SUCCESSFULLY ==="
echo "Application URL: https://$DOMAIN_NAME"
