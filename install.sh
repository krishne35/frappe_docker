#!/bin/bash
# ── Configuration ──────────────────────────────────────────────
FRAPPE_PATH="https://github.com/frappe/frappe"
FRAPPE_BRANCH="version-15"
CUSTOM_IMAGE="ghcr.io/krishne35/frappe_docker/erpimage"
CUSTOM_TAG="15.0.4"
APPS_FILE="/root/frappe_docker/apps.json"
CONTAINERFILE="/root/frappe_docker/images/layered/Containerfile"
PUSH_IMAGE=true  # Set to false to skip docker push
# ── Encode apps.json ───────────────────────────────────────────
if [[ ! -f "$APPS_FILE" ]]; then
  echo "❌  $APPS_FILE not found!"
  exit 1
fi
echo "🔐 Encoding apps.json to Base64..."
APPS_JSON_BASE64=$(base64 -w 0 "$APPS_FILE")
# ── Build Docker Image ─────────────────────────────────────────
echo "🔧 Building Docker image..."
docker build \
  --build-arg=FRAPPE_PATH="$FRAPPE_PATH" \
  --build-arg=FRAPPE_BRANCH="$FRAPPE_BRANCH" \
  --build-arg=APPS_JSON_BASE64="$APPS_JSON_BASE64" \
  --tag="${CUSTOM_IMAGE}:${CUSTOM_TAG}" \
  --file="$CONTAINERFILE" .
# ── Optional Push ──────────────────────────────────────────────
docker tag "${CUSTOM_IMAGE}:${CUSTOM_TAG}" "${CUSTOM_IMAGE}:latest"
if $PUSH_IMAGE; then
  echo "📦 Pushing image to registry..."
  docker push "${CUSTOM_IMAGE}:${CUSTOM_TAG}"
  docker push "${CUSTOM_IMAGE}:latest"
  echo "🆕 Also pushed latest tag."
else
  echo "🚫 Image push skipped."
fi
