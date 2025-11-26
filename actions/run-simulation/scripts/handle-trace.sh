#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${TRACE_PATH:?TRACE_PATH is required}"

sudo mkdir -p /data
sudo chown ubuntu:ubuntu /data

if [ ! -f "$TRACE_PATH" ]; then
    printf "ERROR: Trace file not found at %s\n" "$TRACE_PATH"
    exit 1
fi

cp "$TRACE_PATH" /data/trace

if [ ! -s /data/trace ]; then
    printf "ERROR: Trace file is empty\n"
    exit 1
fi

printf "Validating trace file...\n"
if ! skctl validate check /data/trace; then
    printf "ERROR: Trace file validation failed\n"
    exit 1
fi
