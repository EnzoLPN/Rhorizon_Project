#!/usr/bin/env bash
set -euo pipefail

# Script to install Kyverno and configure Cosign Image Verification on EKS
# Usage: ./install-kyverno.sh

# Go to script directory
cd "$(dirname "${BASH_SOURCE[0]}")"

echo "=== 1. Checking tools ==="
if ! command -v helm &> /dev/null; then
  echo "❌ Error: helm is not installed."
  exit 1
fi
if ! command -v kubectl &> /dev/null; then
  echo "❌ Error: kubectl is not installed."
  exit 1
fi

echo -e "\n=== 2. Adding Kyverno Helm Repository ==="
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

echo -e "\n=== 3. Installing Kyverno (Admission Controller) ==="
# Install Kyverno in the kyverno namespace
kubectl create namespace kyverno --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install kyverno kyverno/kyverno \
  --namespace kyverno \
  --set admissionController.replicas=2 \
  --set backgroundController.replicas=2 \
  --set cleanupController.replicas=2 \
  --set reportsController.replicas=2

echo -e "\n=== 4. Checking Cosign keys ==="
KEY_FILE="cosign.key"
PUB_FILE="cosign.pub"

if [ ! -f "$KEY_FILE" ] || [ ! -f "$PUB_FILE" ]; then
  if ! command -v cosign &> /dev/null; then
    echo "⚠️ Warning: 'cosign' CLI is not installed locally. Cannot generate keys."
    echo "To generate keys manually, run:"
    echo "  cosign generate-key-pair"
    echo "Then save 'cosign.key' and 'cosign.pub' in this directory."
    exit 1
  else
    echo "🔑 Generating Cosign key-pair..."
    cosign generate-key-pair
    echo "Keys generated: $KEY_FILE and $PUB_FILE"
    echo "--------------------------------------------------------"
    echo "👉 IMPORTANT: Add the content of '$KEY_FILE' as a GitHub Secret"
    echo "   named COSIGN_PRIVATE_KEY in your repository settings."
    echo "👉 Add your password as COSIGN_PASSWORD in GitHub Secrets."
    echo "--------------------------------------------------------"
  fi
fi

echo -e "\n=== 5. Injecting public key and applying Kyverno policy ==="
# Format public key with 8-spaces indentation for yaml multiline block compatibility
export COSIGN_PUBLIC_KEY=$(cat "$PUB_FILE" | sed 's/^/        /')

# Interpolate template using envsubst
GENERATED_POLICY="image-verification-policy.yaml"
envsubst < image-verification-policy.yaml.tmpl > "$GENERATED_POLICY"

echo "Applying ClusterImagePolicy to the EKS cluster..."
kubectl apply -f "$GENERATED_POLICY"

echo -e "\n🚀 === KYVERNO & COSIGN SIGNATURE VERIFICATION ENFORCED ==="
echo "Any deployment using an unsigned image matching 'rhzorion/*' will now be rejected by EKS."
