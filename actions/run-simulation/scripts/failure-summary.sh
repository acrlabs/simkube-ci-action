#!/bin/bash
set -euo pipefail

printf "\n❌ Simulation FAILED\n"
printf "Expand for details below:\n"

printf "::group::🚥 Simulation Status:\n"
printf "-----------------------------------------\n"
printf "Running: kubectl describe simulation %s\n" "$SIMULATION_NAME"
printf "-----------------------------------------\n"
kubectl describe simulation "$SIMULATION_NAME" || true
printf "-----------------------------------------\n"
printf "::endgroup::\n"

printf "::group::📄 Simulation YAML\n"
printf "-----------------------------------------\n"
printf "Running: kubectl get simulation %s -o yaml\n" "$SIMULATION_NAME"
printf "-----------------------------------------\n"
kubectl get simulation "$SIMULATION_NAME" -o yaml || true
printf "-----------------------------------------\n"
printf "::endgroup::\n"

printf "🪵 Pod logs tail=100:\n"
printf "::group::sk-ctrl logs:\n"
printf "-----------------------------------------\n"
printf "Running: kubectl logs -n simkube -l app.kubernetes.io/name=sk-ctrl --all-containers --tail=100"
printf "-----------------------------------------\n"
kubectl logs -n simkube -l app.kubernetes.io/name=sk-ctrl --all-containers --tail=100 || true
printf "-----------------------------------------\n"
printf "::endgroup::\n"

printf "::group::sk-tracer logs:\n"
printf "-----------------------------------------\n"
printf "Running: kubectl logs -n simkube -l app.kubernetes.io/name=sk-tracer --all-containers --tail=100\n"
printf "-----------------------------------------\n"
kubectl logs -n simkube -l app.kubernetes.io/name=sk-tracer --all-containers --tail=100 || true
printf "-----------------------------------------\n"
printf "::endgroup::\n"

printf "::group::sk-test-sim-driver logs:\n"
printf "-----------------------------------------\n"
printf "Running: kubectl logs -n simkube -l job-name=sk-test-sim-driver --all-containers --tail=100\n"
printf "-----------------------------------------\n"
kubectl logs -n simkube -l job-name=sk-test-sim-driver --all-containers --tail=100 || true
printf "-----------------------------------------\n"
printf "::endgroup::\n"

printf "::group::📦 All Pods in simkube namespace:\n"
printf "-----------------------------------------\n"
printf "Running: kubectl get pods -n simkube\n"
printf "-----------------------------------------\n"
kubectl get pods -n simkube || true
printf "-----------------------------------------\n"
printf "::endgroup::\n"

printf "::group::📝 Recent events tail=20:\n"
printf "-----------------------------------------\n"
printf "Running: kubectl get events -n simkube --sort-by='.lastTimestamp' | tail -n 20\n"
printf "-----------------------------------------\n"
kubectl get events -n simkube --sort-by='.lastTimestamp' | tail -n 20 || true
printf "-----------------------------------------\n"
printf "::endgroup::\n"

printf "::group::🌎 Get all:\n"
printf "-----------------------------------------\n"
printf "Running: kubectl get all --all-namespaces\n"
printf "-----------------------------------------\n"
kubectl get all --all-namespaces || true
printf "-----------------------------------------\n"
printf "::endgroup::\n"
