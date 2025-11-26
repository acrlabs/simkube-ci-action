#!/bin/bash
set -euo pipefail

: "${SIMULATION_NAME:?SIMULATION_NAME is required}"

echo ""
echo "❌ Simulation FAILED"
echo "Expand for details below:"
echo ""

echo "::group::🚥 Simulation Status:"
echo "-----------------------------------------"
echo "Running: kubectl describe simulation ""$SIMULATION_NAME"""
echo "-----------------------------------------"
kubectl describe simulation "$SIMULATION_NAME" || true
echo "-----------------------------------------"
echo "::endgroup::"
echo ""

echo "::group::📄 Simulation YAML"
echo "-----------------------------------------"
echo "Running: kubectl get simulation ""$SIMULATION_NAME"" -o yaml"
echo "-----------------------------------------"
kubectl get simulation "$SIMULATION_NAME" -o yaml || true
echo "-----------------------------------------"
echo "::endgroup::"
echo ""

echo "🪵 Pod logs tail=100:"
echo "::group::sk-ctrl logs:"
echo "-----------------------------------------"
echo "Running: kubectl logs -n simkube -l app.kubernetes.io/name=sk-ctrl --all-containers --tail=100"
echo "-----------------------------------------"
kubectl logs -n simkube -l app.kubernetes.io/name=sk-ctrl --all-containers --tail=100 || true
echo "-----------------------------------------"
echo "::endgroup::"
echo ""

echo "::group::sk-tracer logs:"
echo "-----------------------------------------"
echo "Running: kubectl logs -n simkube -l app.kubernetes.io/name=sk-tracer --all-containers --tail=100"
echo "-----------------------------------------"
kubectl logs -n simkube -l app.kubernetes.io/name=sk-tracer --all-containers --tail=100 || true
echo "-----------------------------------------"
echo "::endgroup::"
echo ""

echo "::group::sk-test-sim-driver logs:"
echo "-----------------------------------------"
echo "Running: kubectl logs -n simkube -l job-name=sk-test-sim-driver --all-containers --tail=100"
echo "-----------------------------------------"
kubectl logs -n simkube -l job-name=sk-test-sim-driver --all-containers --tail=100 || true
echo "-----------------------------------------"
echo "::endgroup::"
echo ""

echo "::group::📦 All Pods in simkube namespace:"
echo "-----------------------------------------"
echo "Running: kubectl get pods -n simkube"
echo "-----------------------------------------"
kubectl get pods -n simkube || true
echo "-----------------------------------------"
echo "::endgroup::"
echo ""

echo "::group::📝 Recent events tail=20:"
echo "-----------------------------------------"
echo "Running: kubectl get events -n simkube --sort-by='.lastTimestamp' | tail -n 20"
echo "-----------------------------------------"
kubectl get events -n simkube --sort-by='.lastTimestamp' | tail -n 20 || true
echo "-----------------------------------------"
echo "::endgroup::"
echo ""

echo "::group::🌎 Get all:"
echo "-----------------------------------------"
echo "Running: kubectl get all --all-namespaces"
echo "-----------------------------------------"
kubectl get all --all-namespaces || true
echo "-----------------------------------------"
echo "::endgroup::"
echo ""
