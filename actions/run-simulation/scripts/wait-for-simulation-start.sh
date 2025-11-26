#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${SIMULATION_NAME:?SIMULATION_NAME is required}"

printf "Waiting for simulation to reach Running state...\n"
kubectl wait --for=jsonpath='{.status.state}'=Running simulation/"$SIMULATION_NAME" --timeout 5m
printf "✓ Simulation is running!\n"
