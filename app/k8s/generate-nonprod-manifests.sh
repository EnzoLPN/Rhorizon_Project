#!/usr/bin/env bash
set -euo pipefail

# Configuration
LIVE_DIR="../../live/nonprod"
OUTPUT_DIR="nonprod"
AWS_PROFILE="aws-nonprod"

# Go to script directory
cd "$(dirname "${BASH_SOURCE[0]}")"

echo "=== 1. Reading Terraform outputs ==="
if [ ! -f "$LIVE_DIR/terraform.tfstate" ]; then
    echo "❌ Error: terraform.tfstate not found in $LIVE_DIR. Has terraform apply finished?"
    exit 1
fi

echo "Querying terraform outputs..."
TF_OUTPUTS=$(terraform -chdir="$LIVE_DIR" output -json)

# Parse output values
RDS_ENDPOINT_FULL=$(echo "$TF_OUTPUTS" | jq -r '.rds_endpoint.value')
DB_HOST="${RDS_ENDPOINT_FULL%%:*}"
ACM_CERT_ARN=$(echo "$TF_OUTPUTS" | jq -r '.acm_certificate_arn.value')
WAF_ACL_ARN=$(echo "$TF_OUTPUTS" | jq -r '.waf_web_acl_arn.value')
OIDC_ARN=$(echo "$TF_OUTPUTS" | jq -r '.oidc_provider_arn.value')

# Extract AWS Account ID from OIDC ARN (e.g. arn:aws:iam::083127296598:oidc-provider/...)
AWS_ACCOUNT_ID=$(echo "$OIDC_ARN" | cut -d':' -f5)

echo "Parsed settings:"
echo "  - DB Host: $DB_HOST"
echo "  - ACM Cert ARN: $ACM_CERT_ARN"
echo "  - WAF Web ACL ARN: $WAF_ACL_ARN"
echo "  - AWS Account ID: $AWS_ACCOUNT_ID"

# Create output dir
mkdir -p "$OUTPUT_DIR"

echo -e "\n=== 2. Creating Namespace and Network Policy ==="
# Namespace
cat << 'EOF' > "$OUTPUT_DIR/namespace.yaml"
apiVersion: v1
kind: Namespace
metadata:
  name: rhorizon
  labels:
    name: rhorizon
EOF

# Network Policy
cat << 'EOF' > "$OUTPUT_DIR/network-policy.yaml"
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-external-to-frontend
  namespace: rhorizon
spec:
  podSelector:
    matchLabels:
      app: rhorizon-frontend
  policyTypes:
  - Ingress
  ingress:
  - ports:
    - protocol: TCP
      port: 8080
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: rhorizon
spec:
  podSelector:
    matchLabels:
      app: rhorizon-backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: rhorizon-frontend
    ports:
    - protocol: TCP
      port: 5000
EOF

echo "=== 3. Creating Frontend Manifest ==="
cat << EOF > "$OUTPUT_DIR/frontend.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rhorizon-frontend
  namespace: rhorizon
  labels:
    app: rhorizon-frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: rhorizon-frontend
  template:
    metadata:
      labels:
        app: rhorizon-frontend
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 101
      containers:
      - name: frontend
        image: 116101833976.dkr.ecr.eu-west-1.amazonaws.com/rhzorion/frontend:v1.0.1
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          name: http
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 100m
            memory: 128Mi
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 15
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: rhorizon
  labels:
    app: rhorizon-frontend
spec:
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
    name: http
  selector:
    app: rhorizon-frontend
EOF

echo "=== 4. Creating Backend Manifest ==="
cat << EOF > "$OUTPUT_DIR/backend.yaml"
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
  namespace: rhorizon
data:
  DB_HOST: "$DB_HOST"
  DB_PORT: "5432"
  DB_NAME: "rhorizon_dev"
  DB_USER: "dbadmin"
  S3_BUCKET_NAME: "rhorizon-monprojet-app-assets"
  AWS_REGION: "eu-west-1"
---
apiVersion: v1
kind: Secret
metadata:
  name: backend-secret
  namespace: rhorizon
type: Opaque
data:
  # Base64 encoded representation of: RHZorionDevPass2026!
  DB_PASSWORD: "Ukhab3Jpb25EZXZQYXNzMjAyNiE="
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: rhorizon-backend-sa
  namespace: rhorizon
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::$AWS_ACCOUNT_ID:role/rhorizon-nonprod-backend-s3-role"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rhorizon-backend
  namespace: rhorizon
  labels:
    app: rhorizon-backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: rhorizon-backend
  template:
    metadata:
      labels:
        app: rhorizon-backend
    spec:
      serviceAccountName: rhorizon-backend-sa
      securityContext:
        runAsNonRoot: true
        runAsUser: 10001
      containers:
      - name: backend
        image: 116101833976.dkr.ecr.eu-west-1.amazonaws.com/rhzorion/backend:v1.0.1
        imagePullPolicy: Always
        ports:
        - containerPort: 5000
          name: http
        envFrom:
        - configMapRef:
            name: backend-config
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: backend-secret
              key: DB_PASSWORD
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        livenessProbe:
          httpGet:
            path: /api/liveness
            port: 5000
          initialDelaySeconds: 15
          periodSeconds: 15
        readinessProbe:
          httpGet:
            path: /api/health
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: rhorizon
  labels:
    app: rhorizon-backend
spec:
  ports:
  - port: 5000
    targetPort: 5000
    protocol: TCP
    name: http
  selector:
    app: rhorizon-backend
EOF

echo "=== 5. Creating Ingress Manifest ==="
cat << EOF > "$OUTPUT_DIR/ingress.yaml"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rhorizon-ingress
  namespace: rhorizon
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
    alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
    alb.ingress.kubernetes.io/certificate-arn: "$ACM_CERT_ARN"
    alb.ingress.kubernetes.io/wafv2-acl-arn: "$WAF_ACL_ARN"
    alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS-1-2-Ext-2018-06
spec:
  rules:
  - host: nonprod.rhorizon.xyz
    http:
      paths:
      - path: /*
        pathType: ImplementationSpecific
        backend:
          service:
            name: ssl-redirect
            port:
              name: use-annotation
      - path: /api/*
        pathType: ImplementationSpecific
        backend:
          service:
            name: backend
            port:
              number: 5000
      - path: /*
        pathType: ImplementationSpecific
        backend:
          service:
            name: frontend
            port:
              number: 80
EOF

echo "🚀 === NONPROD K8S MANIFESTS GENERATED SUCCESSFUL ==="
echo "Manifests are saved in: app/k8s/$OUTPUT_DIR"
