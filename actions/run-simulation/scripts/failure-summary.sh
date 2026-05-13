#!/bin/bash
set -euo pipefail

# Get the logs from pods that are in CrashLoopBackOff
_print_crashloop_logs() {
    kubectl get pods -A -o json \
      | jq -r '.items[] | select(.status.containerStatuses[]?.state.waiting.reason == "CrashLoopBackOff") | "\(.metadata.namespace) \(.metadata.name)"' \
      | while read -r ns pod; do
          echo "=== $ns/$pod [previous] ==="
          kubectl logs -n "$ns" "$pod" --all-containers --previous
          echo "=== $ns/$pod ==="
          kubectl logs -n "$ns" "$pod" --all-containers
        done
}
export -f _print_crashloop_logs

# Print a command and run it inside a GitHub Actions group
_run_group() {
    local group_name=$1
    local cmd_str=$2

    printf "::group::%s\n" "$group_name"
    printf -- "-----------------------------------------\n"
    printf "Running: %s\n" "$cmd_str"
    printf -- "-----------------------------------------\n"
    bash -c "$cmd_str" || true
    printf -- "-----------------------------------------\n"
    printf "::endgroup::\n"
}

printf "\n❌ Simulation FAILED\n"
printf "Expand for details below:\n"

# format: "group name" then command
_run_group "🚥 Simulation Status" "kubectl describe simulation \"$SIMULATION_NAME\""
_run_group "📄 Simulation YAML" "kubectl get simulation \"$SIMULATION_NAME\" -o yaml"
_run_group "sk-ctrl logs" "kubectl logs -n simkube -l app.kubernetes.io/name=sk-ctrl --all-containers --tail=100"
_run_group "sk-test-sim-driver logs" "kubectl logs -n simkube -l job-name=sk-test-sim-driver --all-containers --tail=100"
_run_group "🕸️ Get all Nodes in simkube namespace" "kubectl get nodes -n simkube"
_run_group "📦 All Pods in simkube namespace" "kubectl get pods -n simkube"
_run_group "📝 Recent events tail=20" "kubectl get events -n simkube --sort-by='.lastTimestamp' | tail -n 20"
_run_group "🌎 Get all" "kubectl get all --all-namespaces"
_run_group "❗ Get failing pod logs" "_print_crashloop_logs"
