#!/bin/bash
set -euo pipefail

: "${SIMULATION_NAME:?SIMULATION_NAME is required}"

echo ""
echo "❌ Simulation FAILED"
echo "Expand for details below:"
echo ""

echo "::group::🚥 Simulation Status"
kubectl describe simulation "$SIMULATION_NAME" || true
echo "-----------------------------------------"
echo "::endgroup::"
echo ""

echo "::group::📄 Simulation YAML"
kubectl get simulation "$SIMULATION_NAME" -o yaml || true
echo "-----------------------------------------"
echo "::endgroup::"
echo ""

echo "🪵 Pod logs tail=100:"
echo "::group::▶ sk-ctrl logs"
kubectl logs -n simkube -l app.kubernetes.io/name=sk-ctrl --all-containers --tail=100 || true
echo "-----------------------------------------"
echo "::endgroup::"
echo ""

echo "::group::▶ sk-tracer logs"
kubectl logs -n simkube -l app.kubernetes.io/name=sk-tracer --all-containers --tail=100 || true
echo "-----------------------------------------"
echo "::endgroup::"
echo ""

echo "::group::▶ sk-test-sim-driver logs"
kubectl logs -n simkube -l job-name=sk-test-sim-driver --all-containers --tail=100 || true
echo "-----------------------------------------"
echo "::endgroup::"
echo ""

echo "::group::📦 All Pods in simkube namespace"
kubectl get pods -n simkube || true
echo "-----------------------------------------"
echo "::endgroup::"
echo ""

echo "::group::📝 Recent events tail=20"
kubectl get events -n simkube --sort-by='.lastTimestamp' | tail -n 20 || true
echo "-----------------------------------------"
echo "::endgroup::"
echo ""

echo "::group::🌎 Get all"
kubectl get all --all-namespaces || true
echo "::endgroup::"
echo "-----------------------------------------"
echo ""
