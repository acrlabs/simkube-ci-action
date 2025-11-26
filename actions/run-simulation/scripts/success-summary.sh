#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${SIMULATION_NAME:?SIMULATION_NAME is required}"

printf "\nSimulation Completed!\n\n"
printf "Name: %s\n" "$SIMULATION_NAME"
printf "Completed at: %s\n" "$(date)"
