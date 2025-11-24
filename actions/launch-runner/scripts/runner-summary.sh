#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${INSTANCE_ID:?INSTANCE_ID is required}"
: "${RUNNER_NAME:?RUNNER_NAME is required}"
: "${AWS_REGION:?AWS_REGION is required}"
: "${INSTANCE_TYPE:?INSTANCE_TYPE is required}"
: "${RUNNER_LABELS:?RUNNER_LABELS are required}"

# Runner summary output
echo "Runner Launch Successful"
echo "Instance ID: \"$INSTANCE_ID\""
echo "Runner Name: \"$RUNNER_NAME\""
echo "Region: \"$AWS_REGION\""
echo "Instance Type: \"$INSTANCE_TYPE\""
echo ""
echo "The runner is now available for jobs with labels: \"$RUNNER_LABELS\""
echo "The runner will automatically terminate after completing one job (ephemeral mode)."
