#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${SIMULATION_NAME:?SIMULATION_NAME is required}"

echo "Waiting for simulation to complete..."
kubectl wait --for=condition=Finished simulation/"$SIMULATION_NAME" --timeout 2h
echo "✓ Simulation completed successfully!"
