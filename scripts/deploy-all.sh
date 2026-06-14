#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Adria Reserve Kubernetes Deployment ==="

if ! command -v kubectl &>/dev/null; then
  echo "kubectl not found. Install kubectl first."
  exit 1
fi

echo "Applying namespaces..."
kubectl apply -f "$ROOT/k8s/namespaces/"

deploy_env() {
  local env=$1
  echo "Deploying $env..."
  kubectl apply -f "$ROOT/k8s/$env/all.yaml"
}

deploy_env dev
deploy_env staging
deploy_env production

echo ""
echo "Deployment complete. Check status:"
echo "  kubectl get all -n adria-dev"
echo "  kubectl get all -n adria-staging"
echo "  kubectl get all -n adria-production"
echo ""
echo "Access frontend (Minikube):"
echo "  minikube service adria-frontend -n adria-dev --url"
echo "  minikube service adria-frontend -n adria-staging --url"
echo "  minikube service adria-frontend -n adria-production --url"
