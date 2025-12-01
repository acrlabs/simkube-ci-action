#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${INSTANCE_ID:?ERROR: INSTANCE_ID is required}"
: "${AWS_REGION:?ERROR: AWS_REGION is required}"
: "${REPO:?ERROR: REPO owner/repo is required}"
: "${SIMKUBE_RUNNER_NAME:?ERROR: SIMKUBE_RUNNER_NAME is required}"
: "${GITHUB_PAT:?ERROR: GITHUB_PAT is required}"

MAX_RETRIES=30
SLEEP_INTERVAL=5

# Wait for instance to be running
printf "Waiting for instance %s to reach 'running' state...\n" "$INSTANCE_ID"

aws ec2 wait instance-running \
    --region "$AWS_REGION" \
    --instance-ids "$INSTANCE_ID"

printf "✓ Instance is running\s"

# Wait for GitHub Actions runner registration
printf "Waiting for runner %s to register in %s...\n" "$SIMKUBE_RUNNER_NAME" "$REPO"

for i in $(seq 1 "$MAX_RETRIES"); do
    RUNNER_STATUS=$(curl -sS -H "Authorization: token $GITHUB_PAT" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$REPO/actions/runners" \
        | jq -r --arg name "$SIMKUBE_RUNNER_NAME" '.runners[] | select(.name==$name) | .status')

    if [[ "$RUNNER_STATUS" == "online" ]]; then
        printf "✓ Runner %s is online\n" "$SIMKUBE_RUNNER_NAME"
        exit 0
    fi

    printf "[%d/%d] Runner not online yet. Status: %s. Retrying in %d seconds...\n" "$i" "$MAX_RETRIES" "${RUNNER_STATUS:-unknown}" "$SLEEP_INTERVAL"
    sleep "$SLEEP_INTERVAL"

done

printf "ERROR: Runner %s did not come online after %d seconds\n" "$SIMKUBE_RUNNER_NAME" "$((MAX_RETRIES * SLEEP_INTERVAL))"
exit 1
