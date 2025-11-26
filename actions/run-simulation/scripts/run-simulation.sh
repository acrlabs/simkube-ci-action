#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${SIMULATION_NAME:?SIMULATION_NAME is required}"
: "${TRACE_PATH:?TRACE_PATH is required}"

# Optional inputs
: "${SPEED:-}"        # optional
: "${DURATION:-}"     # optional

# Current PATH
echo "PATH=$PATH"

# Copy trace file to default trace ingress
cp "$TRACE_PATH" /var/kind/cluster/trace

# Function to add optional flags
add_flag() {
    if [ -n "$2" ]; then
    CMD="$CMD --$1 \"$2\""
    fi
}

# Base command
CMD="skctl run --disable-metrics \"$SIMULATION_NAME\" --hooks config/hooks/default.yml"

# Add optional flags
add_flag "speed" "$SPEED"
add_flag "duration" "$DURATION"

echo ""
echo "Command to execute:"
echo "$CMD"
echo ""
echo "Starting simulation..."
eval "$CMD"
