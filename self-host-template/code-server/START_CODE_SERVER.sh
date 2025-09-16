#!/bin/bash

# START_CODE_SERVER.sh
# Script to start code-server with custom configuration

set -e

# Define paths
SCRIPT_DIR="/root"
CONFIG_FILE="$SCRIPT_DIR/config/config.yaml"
LOG_FILE="$SCRIPT_DIR/logs/code-server.log"
PID_FILE="$SCRIPT_DIR/logs/code-server.pid"

# Create logs directory if it doesn't exist
mkdir -p "$SCRIPT_DIR/logs"

# Check if code-server is already running
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "code-server is already running (PID: $PID)"
        exit 0
    else
        # Remove stale PID file
        rm -f "$PID_FILE"
    fi
fi

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found at $CONFIG_FILE"
    exit 1
fi

echo "Starting code-server with custom configuration..."
echo "Config file: $CONFIG_FILE"
echo "Log file: $LOG_FILE"

# Start code-server in background
nohup code-server --config "$CONFIG_FILE" > "$LOG_FILE" 2>&1 &
CODE_SERVER_PID=$!

# Save PID to file
echo "$CODE_SERVER_PID" > "$PID_FILE"

echo "code-server started successfully (PID: $CODE_SERVER_PID)"
echo "Logs are being written to: $LOG_FILE"
echo "Access code-server at: http://127.0.0.1:8080"