#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${AMI_ID:?ERROR: ami-id is required}"
: "${SIMKUBE_RUNNER_PAT:?ERROR: simkube-runner-pat is required}"

# Validate AWS credentials
if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
    printf "ERROR: AWS credentials must be set as environment variables\n"
    printf "Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY\n"
    exit 1
fi
