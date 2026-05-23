#!/usr/bin/env bash
set -euo pipefail

# Configuration
CLUSTER_NAME="nonprod-eks-cluster"
AWS_PROFILE="aws-nonprod"
AWS_REGION="eu-west-1"

# Go to script directory
cd "$(dirname "${BASH_SOURCE[0]}")"

echo "=== 1. Updating kubeconfig for EKS cluster $CLUSTER_NAME ==="
aws eks update-kubeconfig --name "$CLUSTER_NAME" --profile "$AWS_PROFILE" --region "$AWS_REGION"

echo -e "\n=== 2. Verifying cluster connectivity ==="
kubectl cluster-info

echo -e "\n=== 3. Generating nonprod manifests ==="
./generate-nonprod-manifests.sh

echo -e "\n=== 4. Applying Kubernetes Manifests ==="
# Apply namespace first to avoid namespace not found race conditions
kubectl apply -f nonprod/namespace.yaml
# Apply the rest of the manifests
kubectl apply -f nonprod/

echo -e "\n=== 5. Waiting for Deployment to roll out ==="
echo "Waiting for backend pods..."
kubectl rollout status deployment/rhorizon-backend -n rhorizon --timeout=180s
echo "Waiting for frontend pods..."
kubectl rollout status deployment/rhorizon-frontend -n rhorizon --timeout=180s

echo -e "\n=== 6. Updating Route 53 DNS record for nonprod.rhorizon.xyz ==="
ALB_HOSTNAME=""
echo "Waiting for ALB DNS hostname to be assigned..."
while [ -z "$ALB_HOSTNAME" ]; do
    ALB_HOSTNAME=$(kubectl get ingress rhorizon-ingress -n rhorizon -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)
    if [ -z "$ALB_HOSTNAME" ]; then
        sleep 5
    fi
done
echo "ALB DNS Hostname: $ALB_HOSTNAME"

# Query the Route53 Zone ID from Terraform outputs
ZONE_ID=$(terraform -chdir="../../live/nonprod" output -raw route53_zone_id)

echo "Updating Route 53 Alias record..."
ALB_HOSTNAME_DOT="${ALB_HOSTNAME}."
aws route53 change-resource-record-sets --profile "$AWS_PROFILE" --region "$AWS_REGION" --hosted-zone-id "$ZONE_ID" --change-batch "{
  \"Comment\": \"Update nonprod.rhorizon.xyz to point to EKS ALB\",
  \"Changes\": [
    {
      \"Action\": \"UPSERT\",
      \"ResourceRecordSet\": {
        \"Name\": \"nonprod.rhorizon.xyz.\",
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

echo -e "\n🚀 === DEPLOYMENT COMPLETED SUCCESSFUL ==="
echo "Ingress resources and application pods are being deployed on AWS EKS!"
echo "Check pods status with: kubectl get pods -n rhorizon"
echo "Check ingress status with: kubectl get ingress -n rhorizon"
echo "Application URL: https://nonprod.rhorizon.xyz"

