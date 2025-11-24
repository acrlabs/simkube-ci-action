#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${INSTANCE_ID:?ERROR: INSTANCE_ID is required}"
: "${AWS_REGION:?ERROR: AWS_REGION is required}"
: "${REPO:?ERROR: REPO owner/repo is required}"
: "${RUNNER_NAME:?ERROR: RUNNER_NAME is required}"
: "${GITHUB_PAT:?ERROR: GITHUB_PAT is required}"

MAX_RETRIES=30
SLEEP_INTERVAL=5

# Wait for instance to be running
echo "Waiting for instance $INSTANCE_ID to reach 'running' state..."

aws ec2 wait instance-running \
    --region "$AWS_REGION" \
    --instance-ids "$INSTANCE_ID"

echo "✓ Instance is running"

# Wait for GitHub Actions runner registration
echo "Waiting for runner '$RUNNER_NAME' to register in '$REPO'..."

for i in $(seq 1 "$MAX_RETRIES"); do
    RUNNER_STATUS=$(curl -sS -H "Authorization: token $GITHUB_PAT" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$REPO/actions/runners" \
        | jq -r --arg name "$RUNNER_NAME" '.runners[] | select(.name==$name) | .status')

    if [[ "$RUNNER_STATUS" == "online" ]]; then
        echo "✓ Runner '$RUNNER_NAME' is online"
        exit 0
    fi

    echo "[$i/$MAX_RETRIES] Runner not online yet. Status: ${RUNNER_STATUS:-unknown}. Retrying in $SLEEP_INTERVAL seconds..."
    sleep "$SLEEP_INTERVAL"

done

echo "ERROR: Runner '$RUNNER_NAME' did not come online after $((MAX_RETRIES * SLEEP_INTERVAL)) seconds"
exit 1
