#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${REPO_URL:?REPO_URL is required}"
: "${RUNNER_LABELS:?RUNNER_LABELS is required}"
: "${SIMKUBE_RUNNER_NAME:?SIMKUBE_RUNNER_NAME is required}"
: "${RUNNER_TOKEN:?RUNNER_TOKEN is required}"
: "${AWS_REGION:?AWS_REGION is required}"
: "${AMI_ID:?AMI_ID is required}"
: "${INSTANCE_TYPE:?INSTANCE_TYPE is required}"
: "${SUBNET_ID:?SUBNET_ID is required}"
: "${SECURITY_GROUP_IDS:?SECURITY_GROUP_IDS is required}"
: "${GITHUB_RUN_ID:?GITHUB_RUN_ID is required}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"

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

# Output for next step in GitHub Action
printf "instance-id=%s\n" "$INSTANCE_ID" >> "$GITHUB_OUTPUT"
printf "✓ Launched instance:%s\n" "$INSTANCE_ID"
