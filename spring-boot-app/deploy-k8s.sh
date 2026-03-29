#!/bin/bash

# Deploy to Kubernetes Script
# Usage: ./deploy-k8s.sh [namespace] [image]

NAMESPACE="${1:-default}"
IMAGE="${2:-hello-world-app:1.0.0}"

echo "Deploying to namespace: $NAMESPACE"
echo "Using image: $IMAGE"

# Create namespace if needed
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Update image in deployment
sed -i.bak "s|image:.*|image: $IMAGE|g" k8s/deployment.yaml

# Apply manifests
echo "Applying ConfigMap..."
kubectl apply -n $NAMESPACE -f k8s/configmap.yaml

echo "Applying Deployment..."
kubectl apply -n $NAMESPACE -f k8s/deployment.yaml

echo "Applying Service..."
kubectl apply -n $NAMESPACE -f k8s/service.yaml

echo ""
echo "✓ Deployment complete!"
echo ""
echo "Check deployment status:"
echo "kubectl get all -n $NAMESPACE -l app=hello-world"
echo ""
echo "View logs:"
echo "kubectl logs -n $NAMESPACE -l app=hello-world -f"
echo ""
echo "Port forward:"
echo "kubectl port-forward -n $NAMESPACE svc/hello-world-app 8080:80"
