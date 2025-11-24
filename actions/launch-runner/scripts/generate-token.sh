#!/usr/bin/env bash
set -euo pipefail

# Validate required inputs
: "${GITHUB_REPO:?ERROR: GITHUB_REPO is required}"
: "${SIMKUBE_RUNNER_PAT:?ERROR: SIMKUBE_RUNNER_PAT is required}"

echo "Generating runner registration token..."

RESPONSE=$(curl -sS -w "\n%{http_code}" -X POST \
    -H "Authorization: token $SIMKUBE_RUNNER_PAT" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runners/registration-token")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

echo "HTTP Status: $HTTP_CODE"

if [ "$HTTP_CODE" != "201" ]; then
    echo "ERROR: API request failed"
    echo "Response body: $BODY"
fi

# Extract token from response body
TOKEN=$(echo "$BODY" | jq -r .token)

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    echo "ERROR: Failed to generate runner token"
    echo "Verify your GitHub PAT has 'repo' scope and hasn't expired"
    exit 1
fi

# Set output for next step in GitHub Action
echo "token=$TOKEN" >> "$GITHUB_OUTPUT"
echo "✓ Generated runner registration token"
