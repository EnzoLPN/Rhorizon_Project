#!/usr/bin/env bash
set -euo pipefail

# Generic deployment script using templates
# Usage: ./deploy.sh [backend|frontend|all]

COMPONENT="${1:-all}"
if [[ "$COMPONENT" != "backend" && "$COMPONENT" != "frontend" && "$COMPONENT" != "all" ]]; then
  echo "❌ Error: Invalid component '$COMPONENT'. Must be 'backend', 'frontend', or 'all'."
  exit 1
fi

# Go to script directory
cd "$(dirname "${BASH_SOURCE[0]}")"

echo "=== 1. Checking required environment variables for component: $COMPONENT ==="

# Global required variables
GLOBAL_VARS=(
  "PROJECT_NAME"
  "IMAGE_TAG"
  "ECR_REGISTRY"
  "AWS_REGION"
  "ACM_CERT_ARN"
  "WAF_ACL_ARN"
  "DOMAIN_NAME"
)

# Backend-specific variables
BACKEND_VARS=(
  "ECR_BACKEND_REPOSITORY"
  "DB_HOST"
  "DB_NAME"
  "DB_USER"
  "DB_PASSWORD_BASE64"
  "S3_BUCKET_NAME"
  "BACKEND_ROLE_ARN"
)

# Frontend-specific variables
FRONTEND_VARS=(
  "ECR_FRONTEND_REPOSITORY"
)

# Check global variables
for VAR in "${GLOBAL_VARS[@]}"; do
  if [ -z "${!VAR:-}" ]; then
    echo "❌ Error: Environment variable $VAR is not set."
    exit 1
  fi
done

# Check backend variables if applicable
if [[ "$COMPONENT" == "backend" || "$COMPONENT" == "all" ]]; then
  for VAR in "${BACKEND_VARS[@]}"; do
    if [ -z "${!VAR:-}" ]; then
      echo "❌ Error: Environment variable $VAR is not set (required for backend)."
      exit 1
    fi
  done
fi

# Check frontend variables if applicable
if [[ "$COMPONENT" == "frontend" || "$COMPONENT" == "all" ]]; then
  for VAR in "${FRONTEND_VARS[@]}"; do
    if [ -z "${!VAR:-}" ]; then
      echo "❌ Error: Environment variable $VAR is not set (required for frontend)."
      exit 1
    fi
  done
fi

echo "All required environment variables for $COMPONENT are set."

echo -e "\n=== 2. Creating generated directory ==="
GENERATED_DIR="generated"
mkdir -p "$GENERATED_DIR"

echo -e "\n=== 3. Interpolating templates using envsubst ==="
# Interpolate all templates
envsubst < templates/namespace.yaml.tmpl > "$GENERATED_DIR/namespace.yaml"
envsubst < templates/network-policy.yaml.tmpl > "$GENERATED_DIR/network-policy.yaml"
# Always interpolate ingress
envsubst < templates/ingress.yaml.tmpl > "$GENERATED_DIR/ingress.yaml"

if [[ "$COMPONENT" == "backend" || "$COMPONENT" == "all" ]]; then
  envsubst < templates/backend.yaml.tmpl > "$GENERATED_DIR/backend.yaml"
fi

if [[ "$COMPONENT" == "frontend" || "$COMPONENT" == "all" ]]; then
  envsubst < templates/frontend.yaml.tmpl > "$GENERATED_DIR/frontend.yaml"
fi

echo "Generated interpolated manifests in $GENERATED_DIR/"

echo -e "\n=== 4. Applying Kubernetes Manifests ==="
kubectl apply -f "$GENERATED_DIR/namespace.yaml"
kubectl apply -f "$GENERATED_DIR/network-policy.yaml"

if [[ "$COMPONENT" == "backend" || "$COMPONENT" == "all" ]]; then
  kubectl apply -f "$GENERATED_DIR/backend.yaml"
fi

if [[ "$COMPONENT" == "frontend" || "$COMPONENT" == "all" ]]; then
  kubectl apply -f "$GENERATED_DIR/frontend.yaml"
fi

# Always apply ingress
kubectl apply -f "$GENERATED_DIR/ingress.yaml"

echo -e "\n=== 5. Waiting for Deployments to roll out ==="
if [[ "$COMPONENT" == "backend" || "$COMPONENT" == "all" ]]; then
  kubectl rollout status deployment/${PROJECT_NAME}-backend -n ${PROJECT_NAME} --timeout=180s
fi

if [[ "$COMPONENT" == "frontend" || "$COMPONENT" == "all" ]]; then
  kubectl rollout status deployment/${PROJECT_NAME}-frontend -n ${PROJECT_NAME} --timeout=180s
fi

echo -e "\n=== 6. Updating Route 53 DNS record for $DOMAIN_NAME ==="
ALB_HOSTNAME=""
echo "Waiting for ALB DNS hostname to be assigned..."
# Poll for up to 3 minutes
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

# Query the Route53 Zone ID dynamically from AWS
echo "Querying Route 53 Zone ID for $DOMAIN_NAME..."
ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name "$DOMAIN_NAME" --query "HostedZones[0].Id" --output text | cut -d'/' -f3)

if [ -z "$ZONE_ID" ] || [ "$ZONE_ID" == "None" ]; then
  echo "❌ Error: Could not find hosted zone for $DOMAIN_NAME."
  exit 1
fi
echo "Hosted Zone ID: $ZONE_ID"

echo "Updating Route 53 Alias record..."
ALB_HOSTNAME_DOT="${ALB_HOSTNAME}."
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
          \"DNSName\": \"$ALB_HOSTNAME_DOT\",
          \"EvaluateTargetHealth\": false
        }
      }
    }
  ]
}"

echo -e "\n🚀 === DEPLOYMENT COMPLETED SUCCESSFULLY ==="
echo "Application URL: https://$DOMAIN_NAME"
