#!/usr/bin/env bash
set -euo pipefail
APP_NAME="hello-world-three"
APP_DIR="/opt/apps/${APP_NAME}"

echo "[deploy] Pulling..."
cd "${APP_DIR}" && git pull origin main

echo "[deploy] Installing dependencies..."
npm install --quiet --omit=dev 2>&1

echo "[deploy] Restarting service..."
sudo systemctl restart app-${APP_NAME}
systemctl is-active --quiet app-${APP_NAME} && echo "[deploy] Running."
