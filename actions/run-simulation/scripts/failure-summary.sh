#!/bin/bash
set -euo pipefail

: "${SIMULATION_NAME:?SIMULATION_NAME is required}"

echo ""
echo "Simulation FAILED"
echo "Expand for details below:"
echo ""

echo "::group::Simulation Status"
kubectl describe simulation "$SIMULATION_NAME" || true
echo "::endgroup::"

echo "::group::Simulation YAML"
kubectl get simulation "$SIMULATION_NAME" -o yaml || true
echo "::endgroup::"

echo "::group::Pod logs tail=100"
kubectl logs -n simkube -l simulation="$SIMULATION_NAME" --tail=100 || true
echo "::endgroup::"

echo "::group::All Pods in simkube namespace"
kubectl get pods -n simkube || true
echo "::endgroup::"

echo "::group::Recent events tail=20"
kubectl get events -n simkube --sort-by='.lastTimestamp' | tail -n 20 || true
echo "::endgroup::"

echo "::group::Get all"
kubectl get all --all-namespaces || true
echo "::endgroup::"
