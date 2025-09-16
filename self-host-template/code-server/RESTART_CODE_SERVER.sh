#!/bin/bash

# RESTART_CODE_SERVER.sh
# Script to restart code-server

set -e

# Define paths
SCRIPT_DIR="/root"
START_SCRIPT="$SCRIPT_DIR/START_CODE_SERVER.sh"
STOP_SCRIPT="$SCRIPT_DIR/STOP_CODE_SERVER.sh"

echo "Restarting code-server..."

# Check if scripts exist
if [ ! -f "$STOP_SCRIPT" ]; then
    echo "Error: STOP_CODE_SERVER.sh not found at $STOP_SCRIPT"
    exit 1
fi

if [ ! -f "$START_SCRIPT" ]; then
    echo "Error: START_CODE_SERVER.sh not found at $START_SCRIPT"
    exit 1
fi

# Stop code-server
echo "Stopping code-server..."
"$STOP_SCRIPT"

# Wait a moment to ensure clean shutdown
sleep 2

# Start code-server
echo "Starting code-server..."
"$START_SCRIPT"

echo "code-server restart completed."