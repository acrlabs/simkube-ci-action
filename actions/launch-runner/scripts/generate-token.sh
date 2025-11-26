#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${GITHUB_REPOSITORY:?ERROR: GITHUB_REPOSITORY is required}"
: "${SIMKUBE_RUNNER_PAT:?ERROR: SIMKUBE_RUNNER_PAT is required}"

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
TOKEN=$(jq -r .token <<< "$BODY")

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    printf "ERROR: Failed to generate runner token\n"
    printf "Verify your GitHub PAT has 'repo' scope and hasn't expired\n"
    exit 1
fi

# Set output for next step in GitHub Action
printf "token=%s\n" "$TOKEN" >> "$GITHUB_OUTPUT"
printf "✓ Generated runner registration token\n"
