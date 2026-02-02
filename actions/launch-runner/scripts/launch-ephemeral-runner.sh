#!/usr/bin/env bash
set -euo pipefail

printf "Generating runner registration token...\n"

RESPONSE=$(curl -sS -w "\n%{http_code}" -X POST \
    -H "Authorization: token $SIMKUBE_RUNNER_PAT" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runners/registration-token")

HTTP_CODE=$(tail -n1 <<< "$RESPONSE")
BODY=$(head -n-1 <<< "$RESPONSE")

printf "HTTP Status: %s\n" "$HTTP_CODE"

if [ "$HTTP_CODE" != "201" ]; then
    printf "ERROR: API request failed\n"
    printf "Response body: %s\n" "$BODY"
fi

# Extract token from response body
RUNNER_TOKEN=$(jq -r .token <<< "$BODY")
export RUNNER_TOKEN

if [ -z "$RUNNER_TOKEN" ] || [ "$RUNNER_TOKEN" == "null" ]; then
    printf "ERROR: Failed to generate runner token\n"
    printf "Verify your GitHub PAT has 'repo' scope and hasn't expired\n"
    exit 1
fi

printf "✓ Generated runner registration token\n"

printf "Launching EC2 instance in %s...\n" "$AWS_REGION"

# Build tags
TAG_SPECS="ResourceType=instance,Tags=["
TAG_SPECS="${TAG_SPECS}{Key=Name,Value=github-runner-${GITHUB_RUN_ID}},"
TAG_SPECS="${TAG_SPECS}{Key=GitHubRepository,Value=${GITHUB_REPOSITORY}},"
TAG_SPECS="${TAG_SPECS}{Key=GitHubRunId,Value=${GITHUB_RUN_ID}},"
TAG_SPECS="${TAG_SPECS}{Key=ManagedBy,Value=github-actions},"
TAG_SPECS="${TAG_SPECS}{Key=Ephemeral,Value=true}]"

# Launch EC2 instance
printf "Executing: aws ec2 run-instances...\n"
USER_DATA=$(envsubst < "$GITHUB_ACTION_PATH/scripts/user-data.sh")
if ! RESPONSE=$(aws ec2 run-instances \
    --region "$AWS_REGION" \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --instance-initiated-shutdown-behavior terminate \
    --user-data "$USER_DATA" \
    --tag-specifications "$TAG_SPECS" \
    --subnet-id "$SUBNET_ID" \
    --security-group-ids "$SECURITY_GROUP_IDS" \
    2>&1); then
    printf "ERROR: Failed to launch instance\n"
    printf "%s\n" "$RESPONSE"
    exit 1
fi

# Extract instance ID
INSTANCE_ID=$(jq -r '.Instances[0].InstanceId' <<< "$RESPONSE")

if [[ -z "$INSTANCE_ID" || "$INSTANCE_ID" == "null" ]]; then
    printf "ERROR: Could not parse instance ID from response\n"
    printf "%s\n" "$RESPONSE"
    exit 1
fi

printf "✓ Launched instance:%s\n" "$INSTANCE_ID"

# Wait for instance to be running
MAX_RETRIES_LAUNCH="${MAX_RETRIES_LAUNCH:-30}"
SLEEP_INTERVAL_LAUNCH="${SLEEP_INTERVAL_LAUNCH:-5}"

printf "Waiting for instance %s to reach 'running' state...\n" "$INSTANCE_ID"

aws ec2 wait instance-running \
    --region "$AWS_REGION" \
    --instance-ids "$INSTANCE_ID"

printf "✓ Instance is running\n"

# Wait for GitHub Actions runner registration
printf "Waiting for runner %s to register in %s...\n" "$SIMKUBE_RUNNER_NAME" "$GITHUB_REPOSITORY"

for i in $(seq 1 "$MAX_RETRIES_LAUNCH"); do
    RUNNER_STATUS=$(curl -sS -H "Authorization: token $SIMKUBE_RUNNER_PAT" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runners" \
        | jq -r --arg name "$SIMKUBE_RUNNER_NAME" '.runners[] | select(.name==$name) | .status')

    if [[ "$RUNNER_STATUS" == "online" ]]; then
        printf "✓ Runner %s is online\n" "$SIMKUBE_RUNNER_NAME"
        # runner summary
        printf "Instance ID: %s\n" "$INSTANCE_ID"
        printf "Runner Name: %s\n" "$SIMKUBE_RUNNER_NAME"
        printf "Region: %s\n" "$AWS_REGION"
        printf "Instance Type: %s\n\n" "$INSTANCE_TYPE"
        printf "The runner is now available for jobs with labels: %s\n" "$RUNNER_LABELS"
        exit 0
    fi

    printf "[%d/%d] Runner not online yet. Status: %s. Retrying in %d seconds...\n" "$i" "$MAX_RETRIES_LAUNCH" "${RUNNER_STATUS:-unknown}" "$SLEEP_INTERVAL_LAUNCH"
    sleep "$SLEEP_INTERVAL_LAUNCH"

done

printf "ERROR: Runner %s did not come online after %d seconds\n" "$SIMKUBE_RUNNER_NAME" "$((MAX_RETRIES_LAUNCH * SLEEP_INTERVAL_LAUNCH))"
exit 1
