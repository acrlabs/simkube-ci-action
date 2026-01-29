#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${SIMULATION_NAME:?SIMULATION_NAME is required}"
: "${TRACE_PATH:?TRACE_PATH is required}"

# Optional inputs
: "${SPEED:-}"        # optional
: "${DURATION:-}"     # optional

# Wait for cluster to stabilize
printf "Waiting for kwok to be Ready...\n"
kubectl wait --for=condition=Ready pod -n kube-system -l app.kubernetes.io/instance=kwok --timeout=5m
printf "✓ kwok Ready!\n"

printf "Waiting for sk-ctrl deployment to complete...\n"
kubectl rollout status deployment/sk-ctrl-depl -n simkube --timeout=5m
printf "✓ sk-ctrl Ready!\n"

printf "Waiting for cert-manager to be Ready...\n"
kubectl wait --for=condition=Ready pod -n cert-manager --all --timeout=5m
printf "✓ cert-manager Ready!\n"

# Current PATH
printf "PATH=%s\n" "$PATH"

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

printf ""
printf "\nCommand to execute:\n"
printf "%s\n\n" "$CMD"
printf "Starting simulation...\n"
eval "$CMD"
