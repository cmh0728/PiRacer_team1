#!/bin/bash

SERVICE_NAME=piracer-display
SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}.service"
SCRIPT_PATH="/home/team1/piracer_test/src/board/ip_display.py"
PYTHON_PATH="/home/team1/piracer_test/piracer/bin/python3"
WORK_DIR="/home/team1/piracer_test/src"
USER_NAME="team1"

echo "Creating systemd service at ${SERVICE_PATH}..."

# Create systemd service file
sudo tee $SERVICE_PATH > /dev/null <<EOL
[Unit]
Description=PiRacer Display Battery Monitor
After=network.target

[Service]
ExecStart=${PYTHON_PATH} ${SCRIPT_PATH}
WorkingDirectory=${WORK_DIR}
StandardOutput=inherit
StandardError=inherit
Restart=always
User=${USER_NAME}
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, enable and start the service
echo "Enabling and starting the service..."
sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_NAME}.service
sudo systemctl start ${SERVICE_NAME}.service

echo "Service '${SERVICE_NAME}' is now installed and running."
