#!/bin/bash
# Freestyle.sh VM management helpers
# Source this file: source scripts/freestyle-helpers.sh

: "${FREESTYLE_API_KEY:?Set FREESTYLE_API_KEY before using these helpers}"

# Create a new VM and print its ID
freestyle_create_vm() {
    local output
    output=$(npx freestyle vm create 2>&1)
    local vm_id
    vm_id=$(echo "$output" | grep "VM ID:" | awk '{print $NF}')
    echo "$vm_id"
}

# List all VMs: ID and state
freestyle_list_vms() {
    npx freestyle vm list --json | python3 -c "
import sys, json
d = json.load(sys.stdin)
for v in d['vms']:
    print(f\"{v['id']}\t{v['state']}\")"
}

# Execute a command on a VM
# Usage: freestyle_exec <vm-id> "command"
freestyle_exec() {
    local vm_id="$1"
    local cmd="$2"
    npx freestyle vm exec "$vm_id" "$cmd"
}

# Execute a script via stdin on a VM
# Usage: freestyle_exec_script <vm-id> < script.sh
freestyle_exec_script() {
    local vm_id="$1"
    npx freestyle vm exec "$vm_id" 'bash -s'
}

# Delete a single VM
freestyle_delete_vm() {
    local vm_id="$1"
    npx freestyle vm delete "$vm_id"
}

# Delete ALL VMs (use with caution)
freestyle_delete_all_vms() {
    local vm_ids
    vm_ids=$(npx freestyle vm list --json | python3 -c "import sys,json; [print(v['id']) for v in json.load(sys.stdin)['vms']]")
    for vm_id in $vm_ids; do
        echo "Deleting $vm_id..."
        npx freestyle vm delete "$vm_id"
    done
}

# Wait for a command to succeed on a VM
# Usage: freestyle_wait_for <vm-id> "command" [max_attempts] [sleep_seconds]
freestyle_wait_for() {
    local vm_id="$1"
    local cmd="$2"
    local max_attempts="${3:-30}"
    local sleep_sec="${4:-10}"
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if freestyle_exec "$vm_id" "$cmd" >/dev/null 2>&1; then
            echo "Ready after $((attempt * sleep_sec))s"
            return 0
        fi
        attempt=$((attempt + 1))
        echo "Waiting... (attempt $attempt/$max_attempts)"
        sleep "$sleep_sec"
    done
    echo "Timeout after $((max_attempts * sleep_sec))s"
    return 1
}

# Print VM info summary
freestyle_vm_info() {
    local vm_id="$1"
    echo "=== VM: $vm_id ==="
    freestyle_exec "$vm_id" "uname -r && cat /etc/os-release | head -3 && free -h | head -2 && df -h / | tail -1"
}
