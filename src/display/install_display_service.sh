#!/bin/bash

SERVICE_NAME=piracer-display
SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}.service"
CURRENT_DIR=$(pwd)
SCRIPT_PATH="${CURRENT_DIR}/../../src/board/ip_display.py"
PYTHON_PATH="${CURRENT_DIR}/../../piracer/bin/python3"
USER_NAME=$(whoami)

echo "Creating systemd service at ${SERVICE_PATH}..."

sudo tee $SERVICE_PATH > /dev/null <<EOL
[Unit]
Description=PiRacer Display Battery Monitor
After=network.target

[Service]
ExecStart=${PYTHON_PATH} ${SCRIPT_PATH}
WorkingDirectory=${CURRENT_DIR}/src
StandardOutput=inherit
StandardError=inherit
Restart=always
User=${USER_NAME}
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_NAME}.service
sudo systemctl start ${SERVICE_NAME}.service

echo "Service '${SERVICE_NAME}' is now installed and running."

