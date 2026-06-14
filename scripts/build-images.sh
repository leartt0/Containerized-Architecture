#!/usr/bin/env bash
# Build and optionally push Adria Reserve images to Docker Hub.
# Usage: ./scripts/build-images.sh [--push]
# For Minikube local builds: eval $(minikube docker-env) && ./scripts/build-images.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REGISTRY="${DOCKER_REGISTRY:-leartt0}"
TAG="${IMAGE_TAG:-1.0.0}"
PUSH=false

for arg in "$@"; do
  [ "$arg" = "--push" ] && PUSH=true
done

"$ROOT/scripts/prepare-app.sh"

echo "Building backend image..."
docker build -f "$ROOT/docker/backend/Dockerfile" \
  -t "$REGISTRY/adria-reserve-backend:$TAG" \
  -t "$REGISTRY/adria-reserve-backend:latest" \
  "$ROOT/app/backend"

echo "Building frontend image..."
docker build -f "$ROOT/docker/frontend/Dockerfile" \
  --build-arg VITE_API_BASE_URL=/api \
  -t "$REGISTRY/adria-reserve-frontend:$TAG" \
  -t "$REGISTRY/adria-reserve-frontend:latest" \
  "$ROOT/app/frontend"

echo "Images built:"
echo "  $REGISTRY/adria-reserve-backend:$TAG"
echo "  $REGISTRY/adria-reserve-frontend:$TAG"

docker tag "$REGISTRY/adria-reserve-backend:$TAG" "$REGISTRY/adria-reserve-backend:1.0.0-dev"
docker tag "$REGISTRY/adria-reserve-frontend:$TAG" "$REGISTRY/adria-reserve-frontend:1.0.0-dev"
echo "  $REGISTRY/adria-reserve-backend:1.0.0-dev (development tag)"
echo "  $REGISTRY/adria-reserve-frontend:1.0.0-dev (development tag)"

if [ "$PUSH" = true ]; then
  echo "Pushing to Docker Hub..."
  docker push "$REGISTRY/adria-reserve-backend:$TAG"
  docker push "$REGISTRY/adria-reserve-backend:latest"
  docker push "$REGISTRY/adria-reserve-frontend:$TAG"
  docker push "$REGISTRY/adria-reserve-frontend:latest"
  echo "Push complete."
fi
