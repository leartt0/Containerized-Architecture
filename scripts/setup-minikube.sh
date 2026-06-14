#!/usr/bin/env bash
# Minikube bootstrap for Adria Reserve K8s project
set -euo pipefail

echo "Starting Minikube..."
minikube start --cpus=4 --memory=8192 --driver=docker

echo "Enabling metrics-server (required for HPA)..."
minikube addons enable metrics-server

echo ""
echo "Optional: Install VPA for recommendation mode"
echo "  kubectl apply -f https://github.com/kubernetes/autoscaler/releases/latest/download/vertical-pod-autoscaler.yaml"
echo ""
echo "Build images inside Minikube Docker:"
echo "  eval \$(minikube docker-env)"
echo "  ./scripts/build-images.sh"
echo ""
echo "Tag dev images:"
echo "  docker tag leartt0/adria-reserve-backend:1.0.0 leartt0/adria-reserve-backend:1.0.0-dev"
echo "  docker tag leartt0/adria-reserve-frontend:1.0.0 leartt0/adria-reserve-frontend:1.0.0-dev"
echo ""
echo "Deploy:"
echo "  ./scripts/deploy-all.sh"
