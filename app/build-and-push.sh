#!/usr/bin/env bash
set -euo pipefail

# Configuration
AWS_REGION="eu-west-1"
ECR_REGISTRY="116101833976.dkr.ecr.eu-west-1.amazonaws.com"
AWS_PROFILE="${AWS_PROFILE:-}" # Optional: AWS Profile if specified

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Usage message
usage() {
    echo "Usage: $0 [tag]"
    echo "  [tag] : Version tag to apply to the images (default: latest)"
    echo ""
    echo "Environment variables:"
    echo "  AWS_PROFILE : AWS profile to use (e.g. AWS_PROFILE=aws-shared-services $0)"
    echo "  AWS_REGION  : AWS region (default: eu-west-1)"
    exit 1
}

# Check for help flags
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
fi

IMAGE_TAG="${1:-latest}"

# Configure profile argument if set
PROFILE_FLAG=""
if [ -n "$AWS_PROFILE" ]; then
    PROFILE_FLAG="--profile $AWS_PROFILE"
    echo "👉 Using AWS CLI Profile: $AWS_PROFILE"
fi

echo "=== 1. Authenticating with AWS ECR ==="
aws ecr get-login-password --region "$AWS_REGION" $PROFILE_FLAG | \
    docker login --username AWS --password-stdin "$ECR_REGISTRY"

echo -e "\n=== 2. Building Backend Image ==="
docker build -t "$ECR_REGISTRY/rhzorion/backend:$IMAGE_TAG" "$SCRIPT_DIR/backend"

echo -e "\n=== 3. Building Frontend Image ==="
docker build -t "$ECR_REGISTRY/rhzorion/frontend:$IMAGE_TAG" "$SCRIPT_DIR/frontend"

# If a custom tag was passed (i.e. not 'latest'), tag them as 'latest' too for convenience
if [ "$IMAGE_TAG" != "latest" ]; then
    echo -e "\n=== Tagging images as 'latest' for convenience ==="
    docker tag "$ECR_REGISTRY/rhzorion/backend:$IMAGE_TAG" "$ECR_REGISTRY/rhzorion/backend:latest"
    docker tag "$ECR_REGISTRY/rhzorion/frontend:$IMAGE_TAG" "$ECR_REGISTRY/rhzorion/frontend:latest"
fi

echo -e "\n=== 4. Pushing Backend Image to ECR ==="
docker push "$ECR_REGISTRY/rhzorion/backend:$IMAGE_TAG"
if [ "$IMAGE_TAG" != "latest" ]; then
    docker push "$ECR_REGISTRY/rhzorion/backend:latest"
fi

echo -e "\n=== 5. Pushing Frontend Image to ECR ==="
docker push "$ECR_REGISTRY/rhzorion/frontend:$IMAGE_TAG"
if [ "$IMAGE_TAG" != "latest" ]; then
    docker push "$ECR_REGISTRY/rhzorion/frontend:latest"
fi

echo -e "\n🚀 === BUILD AND PUSH SUCCESSFUL ==="
echo "Images pushed to ECR: $ECR_REGISTRY/rhzorion/[backend|frontend]:$IMAGE_TAG"
if [ "$IMAGE_TAG" != "latest" ]; then
    echo "Images also pushed with 'latest' tag."
fi
