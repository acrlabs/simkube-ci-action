#!/usr/bin/env bash
set -euo pipefail

# Make sure skctl can be found
export PATH="/home/ubuntu/.cargo/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

# Copy trace file to expected location
sudo mkdir -p /data
sudo chown ubuntu:ubuntu /data

if [ ! -f "$TRACE_PATH" ]; then
    printf "ERROR: Trace file not found at %s\n" "$TRACE_PATH"
    exit 1
fi

cp "$TRACE_PATH" /data/trace

if [ ! -s /data/trace ]; then
    printf "ERROR: Trace file is empty\n"
    exit 1
fi

printf "Validating trace file...\n"
if ! skctl validate check /data/trace; then
    printf "ERROR: Trace file validation failed\n"
    exit 1
fi

# Wait for cluster to stabilize
printf "Waiting for kwok to be Ready...\n"
kubectl wait --for=condition=Ready pod -n kube-system -l app.kubernetes.io/instance=kwok --timeout=5m
printf "✓ kwok Ready!\n"

printf "Waiting for sk-ctrl to be Ready...\n"
kubectl wait --for=condition=Ready pod -n simkube -l app.kubernetes.io/name=sk-ctrl --timeout=5m
printf "✓ sk-ctrl Ready!\n"

printf "Waiting for cert-manager to be Ready...\n"
kubectl wait --for=condition=Ready pod -n cert-manager --all --timeout=5m
printf "✓ cert-manager Ready!\n"

# Current PATH
printf "PATH=%s\n" "$PATH"

# Copy trace file to default trace ingress
cp "$TRACE_PATH" /var/kind/cluster/trace

# Function to add optional flags
add_flag() {
    if [ -n "$2" ]; then
    CMD="$CMD --$1 \"$2\""
    fi
}

# Base command
CMD="skctl run --disable-metrics \"$SIMULATION_NAME\" --hooks config/hooks/default.yml"

# Add optional flags
add_flag "speed" "$SPEED"
add_flag "duration" "$DURATION"

printf ""
printf "\nCommand to execute:\n"
printf "%s\n\n" "$CMD"
printf "Starting simulation...\n"
eval "$CMD"

# Wait for simulation
printf "Waiting for simulation to reach Running state...\n"
kubectl wait --for=jsonpath='{.status.state}'=Running simulation/"$SIMULATION_NAME" --timeout 5m
printf "✓ Simulation is running!\n"

printf "Waiting for simulation to complete..."
kubectl wait --for=jsonpath='{.status.state}'=Finished simulation/"$SIMULATION_NAME" --timeout 2h
printf "✓ Simulation completed successfully!\n"
printf "Name: %s\n" "$SIMULATION_NAME"
printf "Completed at: %s\n" "$(date)"

MAX_RETRIES_SIM="${MAX_RETRIES_SIM:-720}"
SLEEP_INTERVAL_SIM="${SLEEP_INTERVAL_SIM:-10}"

_get_state() {
    kubectl get simulation "$SIMULATION_NAME" -o jsonpath='{.status.state}' 2>/dev/null || printf ""
}

_wait_for_state() {
    local target_state="$1"
    local state=""
    local retries=0

    while (( retries < MAX_RETRIES_SIM )); do
        state="$(_get_state)"

        case "$state" in
            "Failed")
                printf "Error: Simulation Failed.\n"
                exit 1
                ;;
            "$target_state")
                return 0
                ;;
        esac

        ((retries++))
        sleep "$SLEEP_INTERVAL_SIM"
    done

    printf "ERROR: Timeout waiting for %s state. Last state %s\n" "$target_state" "$state"
    exit 1
}

printf "Waiting for simulation to reach Running state...\n"
_wait_for_state "Running"
printf "✓ Simulation is running!\n"

printf "Waiting for simulation to reach Finished state...\n"
_wait_for_state "Finished"
printf "✓ Simulation completed successfully!\n"
exit 0
