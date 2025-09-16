sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=code-server
Documentation=https://github.com/coder/code-server
After=network.target

[Service]
Type=simple
User=$CURRENT_USER
WorkingDirectory=/root/code-server
ExecStart=$CODE_SERVER_PATH --bind-addr 0.0.0.0:8080 --user-data-dir $HOME/.local/share/code-server --extensions-dir $HOME/.local/share/code-server/extensions
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable the service
sudo systemctl daemon-reload
sudo systemctl enable code-server.service

echo "Code Server auto-restart service has been created and enabled!"
echo "To start the service now: sudo systemctl start code-server"
echo "To check status: sudo systemctl status code-server"
echo "To view logs: sudo journalctl -u code-server -f"
