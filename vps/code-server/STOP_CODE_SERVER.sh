#!/bin/bash

# STOP_CODE_SERVER.sh
# Script to stop code-server

set -e

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/logs/code-server.pid"

# Check if PID file exists
if [ ! -f "$PID_FILE" ]; then
    echo "code-server PID file not found. Is code-server running?"
    
    # Check if any code-server processes are running
    if pgrep -f "code-server" > /dev/null; then
        echo "Found running code-server processes. Attempting to stop them..."
        pkill -f "code-server"
        echo "All code-server processes stopped."
    else
        echo "No code-server processes found running."
    fi
    exit 0
fi

# Read PID from file
PID=$(cat "$PID_FILE")

# Check if process is actually running
if ! ps -p "$PID" > /dev/null 2>&1; then
    echo "Process with PID $PID is not running. Cleaning up PID file."
    rm -f "$PID_FILE"
    exit 0
fi

echo "Stopping code-server (PID: $PID)..."

# Try graceful shutdown first
kill "$PID"

# Wait up to 10 seconds for graceful shutdown
for i in {1..10}; do
    if ! ps -p "$PID" > /dev/null 2>&1; then
        echo "code-server stopped successfully."
        rm -f "$PID_FILE"
        exit 0
    fi
    sleep 1
done

# If still running, force kill
echo "Graceful shutdown failed. Force killing process..."
kill -9 "$PID"

# Wait a bit more and verify
sleep 2
if ! ps -p "$PID" > /dev/null 2>&1; then
    echo "code-server force stopped successfully."
    rm -f "$PID_FILE"
else
    echo "Failed to stop code-server process (PID: $PID)"
    exit 1
fi