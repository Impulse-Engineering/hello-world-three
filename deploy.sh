#!/usr/bin/env bash
set -euo pipefail
APP_NAME="hello-world-three"
APP_DIR="/opt/apps/${APP_NAME}"

echo "[deploy] Pulling..."
cd "${APP_DIR}" && git pull origin main

echo "[deploy] Installing dependencies..."
npm install --quiet --omit=dev 2>&1

echo "[deploy] Configuring port..."
INTERNAL_PORT=$(grep -oP 'proxy_pass http://127\.0\.0\.1:\K\d+' /etc/nginx/sites-available/${APP_NAME})
if grep -q '^PORT=' /etc/apps/${APP_NAME}/.env 2>/dev/null; then
  sudo sed -i "s/^PORT=.*/PORT=${INTERNAL_PORT}/" /etc/apps/${APP_NAME}/.env
else
  echo "PORT=${INTERNAL_PORT}" | sudo tee -a /etc/apps/${APP_NAME}/.env > /dev/null
fi

echo "[deploy] Writing systemd unit..."
cat <<UNIT | sudo tee /etc/systemd/system/app-${APP_NAME}.service > /dev/null
[Unit]
Description=Aseva App - ${APP_NAME}
After=network.target

[Service]
Type=simple
User=app-${APP_NAME}
Group=app-${APP_NAME}
WorkingDirectory=/opt/apps/${APP_NAME}
EnvironmentFile=/etc/apps/${APP_NAME}/.env
ExecStart=/usr/bin/node /opt/apps/${APP_NAME}/src/index.js
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=app-${APP_NAME}
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ReadWritePaths=/opt/apps/${APP_NAME} /var/log/apps/${APP_NAME}

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload

echo "[deploy] Restarting service..."
sudo systemctl restart app-${APP_NAME}
sudo systemctl is-active --quiet app-${APP_NAME} && echo "[deploy] Running."
