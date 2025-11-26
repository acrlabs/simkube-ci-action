#!/bin/bash
set -euo pipefail

printf "Setting up GitHub Runner...\n"

cat > /etc/github-runner.env << 'ENVFILE'
GITHUB_REPOSITORY_URL=${REPO_URL}
GITHUB_RUNNER_LABELS=${RUNNER_LABELS}
GITHUB_RUNNER_NAME=${SIMKUBE_RUNNER_NAME}
GITHUB_RUNNER_TOKEN=${RUNNER_TOKEN}
ENVFILE

printf "✓ Created runner configuration\n"

printf "Starting GitHub Actions runner service...\n"
systemctl start github-runner

until systemctl is-active github-runner | grep -q "active"; do
    printf "Waiting for GitHub Runner service...\n"
    sleep 5
done

printf "✓ Runner service started\n"
printf "Setup complete at: %s\n" "$(date)"
