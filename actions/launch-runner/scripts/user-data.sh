#!/bin/bash
set -euo pipefail

echo "Setting up GitHub Runner..."

cat > /etc/github-runner.env << 'ENVFILE'
GITHUB_REPOSITORY_URL=${REPO_URL}
GITHUB_RUNNER_LABELS=${RUNNER_LABELS}
GITHUB_RUNNER_NAME=${SIMKUBE_RUNNER_NAME}
GITHUB_RUNNER_TOKEN=${RUNNER_TOKEN}
ENVFILE

echo "✓ Created runner configuration"

echo "Starting GitHub Actions runner service..."
systemctl start github-runner

until systemctl is-active github-runner | grep -q "active"; do
    echo "Waiting for GitHub Runner service..."
    sleep 5
done

echo "✓ Runner service started"
echo "Setup complete at: $(date)"
