#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
INFRA_DIR="$ROOT_DIR/infrastructure"
FLUTTER_DIR="$ROOT_DIR/flutter/agrismart_app"

echo "[1/4] Starting backend + ngrok..."
(
  cd "$INFRA_DIR"
  docker compose up -d db auth_service api_gateway ngrok
)

echo "[2/4] Waiting for ngrok tunnel..."
NGROK_URL=""
for _ in $(seq 1 30); do
  NGROK_URL="$(curl -s http://127.0.0.1:4040/api/tunnels | sed -n 's|.*"public_url":"\(https://[^"\\]*\)".*|\1|p' | head -n1 || true)"
  if [[ -n "$NGROK_URL" ]]; then
    break
  fi
  sleep 1
done

if [[ -z "$NGROK_URL" ]]; then
  echo "Could not discover ngrok HTTPS tunnel from http://127.0.0.1:4040/api/tunnels"
  echo "Check: docker compose logs ngrok"
  exit 1
fi

API_URL="$NGROK_URL/api/v1/auth"

echo "[3/4] Tunnel ready: $API_URL"
echo "[4/4] Launching Flutter with API_BASE_URL..."

(
  cd "$FLUTTER_DIR"
  flutter run --dart-define=API_BASE_URL="$API_URL" "$@"
)
