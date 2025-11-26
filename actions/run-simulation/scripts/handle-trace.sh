#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${TRACE_PATH:?TRACE_PATH is required}"

sudo mkdir -p /data
sudo chown ubuntu:ubuntu /data

if [ ! -f "$TRACE_PATH" ]; then
    echo "ERROR: Trace file not found at $TRACE_PATH"
    exit 1
fi

cp "$TRACE_PATH" /data/trace

if [ ! -s /data/trace ]; then
    echo "ERROR: Trace file is empty"
    exit 1
fi

echo "Validating trace file..."
if ! skctl validate check /data/trace; then
    echo "ERROR: Trace file validation failed"
    exit 1
fi
