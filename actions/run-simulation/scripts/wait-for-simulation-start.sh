#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${SIMULATION_NAME:?SIMULATION_NAME is required}"

echo "Waiting for simulation to reach Running state..."
kubectl wait --for=condition=Running simulation/"$SIMULATION_NAME" --timeout 5m
echo "✓ Simulation is running!"
