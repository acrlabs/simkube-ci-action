#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${SIMULATION_NAME:?SIMULATION_NAME is required}"

echo ""
echo "Simulation Completed!"
echo ""
echo "Name:          \"$SIMULATION_NAME\""
echo "Completed at:  $(date)"
echo ""
