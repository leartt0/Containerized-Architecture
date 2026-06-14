#!/usr/bin/env bash
# Copies Adria Reserve source into app/ for Docker builds.
# Expects adria-reserve-2 alongside this repo, or set ADRIA_RESERVE_PATH.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="${ADRIA_RESERVE_PATH:-$ROOT/../adria-reserve-2}"

if [ ! -d "$SOURCE/backend" ]; then
  echo "Error: Adria Reserve not found at $SOURCE"
  echo "Clone it or set ADRIA_RESERVE_PATH=/path/to/adria-reserve-2"
  exit 1
fi

echo "Copying from $SOURCE ..."
rm -rf "$ROOT/app/backend" "$ROOT/app/frontend"
mkdir -p "$ROOT/app/backend" "$ROOT/app/frontend"

rsync -a --exclude node_modules --exclude dist --exclude logs \
  "$SOURCE/backend/" "$ROOT/app/backend/"

rsync -a --exclude node_modules --exclude dist \
  "$SOURCE/package.json" "$SOURCE/package-lock.json" \
  "$SOURCE/index.html" "$SOURCE/vite.config.ts" \
  "$SOURCE/tsconfig.json" "$SOURCE/tsconfig.app.json" \
  "$SOURCE/tsconfig.node.json" "$SOURCE/postcss.config.js" \
  "$SOURCE/tailwind.config.ts" "$SOURCE/components.json" \
  "$SOURCE/public" "$SOURCE/src" \
  "$ROOT/app/frontend/"

cp "$ROOT/docker/frontend/nginx.conf" "$ROOT/app/frontend/nginx.conf"

echo "Done. app/backend and app/frontend are ready for docker build."
