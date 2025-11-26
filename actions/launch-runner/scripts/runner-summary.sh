#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${INSTANCE_ID:?INSTANCE_ID is required}"
: "${SIMKUBE_RUNNER_NAME:?SIMKUBE_RUNNER_NAME is required}"
: "${AWS_REGION:?AWS_REGION is required}"
: "${INSTANCE_TYPE:?INSTANCE_TYPE is required}"
: "${RUNNER_LABELS:?RUNNER_LABELS are required}"

# Runner summary output
printf "Runner Launch Successful!\n"
printf "Instance ID: %s\n" "$INSTANCE_ID"
printf "Runner Name: %s\n" "$SIMKUBE_RUNNER_NAME"
printf "Region: %s\n" "$AWS_REGION"
printf "Instance Type: %s\n\n" "$INSTANCE_TYPE"
printf "The runner is now available for jobs with labels: %s\n" "$RUNNER_LABELS"
printf "The runner will automatically terminate after completing one job (ephemeral mode).\n"
