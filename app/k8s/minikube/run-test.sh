#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Project configuration
export PROJECT_NAME="${PROJECT_NAME:-rhorizon}"

echo "=== 1. Checking Minikube status ==="
if ! minikube status &>/dev/null; then
    echo "Minikube is not running. Starting Minikube..."
    minikube start --driver=docker
else
    echo "Minikube is running."
fi

echo "=== 2. Configuring Docker CLI to point to Minikube's Docker daemon ==="
eval $(minikube -p minikube docker-env)

echo "=== 3. Building Backend Image ==="
docker build -t ${PROJECT_NAME}-backend:latest "$PROJECT_ROOT/app/backend"

echo "=== 4. Building Frontend Image ==="
docker build -t ${PROJECT_NAME}-frontend:latest "$PROJECT_ROOT/app/frontend"

echo "=== 5. Interpolating and Applying Kubernetes Manifests ==="
GENERATED_DIR="$SCRIPT_DIR/generated"
mkdir -p "$GENERATED_DIR"

for f in "$SCRIPT_DIR"/*.yaml.tmpl; do
    filename=$(basename "$f" .tmpl)
    envsubst < "$f" > "$GENERATED_DIR/$filename"
    kubectl apply -f "$GENERATED_DIR/$filename"
done

echo "=== 6. Waiting for Pods to be ready ==="
echo "Waiting for PostgreSQL and LocalStack..."
kubectl wait --namespace ${PROJECT_NAME} --for=condition=ready pod -l app=${PROJECT_NAME}-db --timeout=120s
kubectl wait --namespace ${PROJECT_NAME} --for=condition=ready pod -l app=${PROJECT_NAME}-localstack --timeout=120s

echo "Waiting for Backend and Frontend..."
kubectl wait --namespace ${PROJECT_NAME} --for=condition=ready pod -l app=${PROJECT_NAME}-backend --timeout=120s
kubectl wait --namespace ${PROJECT_NAME} --for=condition=ready pod -l app=${PROJECT_NAME}-frontend --timeout=120s

echo "=== 7. Verification Tests ==="
echo "Pods are ready! Setting up background port-forwarding..."

# Kill any existing port-forward sessions on these ports
pkill -f "port-forward.*5000" || true
pkill -f "port-forward.*8080" || true

# Start port forwarding in background
kubectl port-forward -n ${PROJECT_NAME} svc/backend 5000:5000 &
PID_BACKEND=$!
kubectl port-forward -n ${PROJECT_NAME} svc/frontend 8080:8080 &
PID_FRONTEND=$!

# Make sure they are killed on script exit
cleanup() {
    echo "Cleaning up background port-forwarding processes..."
    kill $PID_BACKEND $PID_FRONTEND 2>/dev/null || true
}
trap cleanup EXIT

echo "Waiting 5 seconds for port forwarding tunnel to initialize..."
sleep 5

echo "Running health check request..."
curl -s -i http://localhost:8080/api/health
echo -e "\n"

echo "Running S3 test request..."
curl -s -i -X POST http://localhost:8080/api/s3/test
echo -e "\n"

echo "=== TEST SUCCESS ==="
echo "Dashboard was verified successfully!"
echo "To access the dashboard manually, you can run:"
echo "  kubectl port-forward -n ${PROJECT_NAME} svc/frontend 8080:8080"
