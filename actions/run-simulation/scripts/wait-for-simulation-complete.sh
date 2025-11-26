#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${SIMULATION_NAME:?SIMULATION_NAME is required}"

printf "Waiting for simulation to complete..."
kubectl wait --for=jsonpath='{.status.state}'=Finished simulation/"$SIMULATION_NAME" --timeout 2h
printf "✓ Simulation completed successfully!"
