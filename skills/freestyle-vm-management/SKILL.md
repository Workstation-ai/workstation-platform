---
name: freestyle-vm-management
description: Manage virtual machines on Freestyle.sh cloud. Use when creating, listing, executing commands on, or deleting Freestyle VMs. Includes API key setup, CLI usage, and known limitations.
compatibility: Requires Node.js (for npx), Freestyle.sh API key, internet access
metadata:
  author: workstation-ai
  version: "1.0"
---

# Freestyle.sh VM Management

Freestyle.sh provides lightweight VMs for serverless functions and simple workloads. Each VM gets Debian 13 trixie, 4 vCPU, 8GB RAM, 16GB disk by default.

## CRITICAL LIMITATION

**Freestyle VMs CANNOT run Kubernetes workloads properly.** While containers start (runc works), pod networking is fundamentally broken:
- No DNS resolution from pods
- No internet access from pods
- Bridge networking does not forward traffic to host interface
- Kernel `6.1.0-15-freestyle` is too restricted

Use Freestyle only for: serverless functions, builds, CI tasks, non-container workloads.

## API Key Setup

Set the environment variable before using the CLI:

```bash
export FREESTYLE_API_KEY="your-api-key-here"
```

Or pass it inline with each command.

## CLI Usage

All commands use `npx freestyle` (no install needed):

```bash
# Create a VM (returns VM ID)
npx freestyle vm create

# List all VMs
npx freestyle vm list --json

# Execute a command on a VM
npx freestyle vm exec <vm-id> "command here"

# Delete a VM
npx freestyle vm delete <vm-id>
```

## Common Operations

### Create and configure a VM

```bash
VM_ID=$(npx freestyle vm create 2>&1 | grep "VM ID:" | awk '{print $NF}')
echo "Created VM: $VM_ID"

# Install packages
npx freestyle vm exec $VM_ID "apt-get update && apt-get install -y kmod iptables"
```

### List all VMs with state

```bash
npx freestyle vm list --json | python3 -c "
import sys, json
d = json.load(sys.stdin)
for v in d['vms']:
    print(f\"{v['id']} ({v['state']})\")"
```

### Execute multi-line scripts

```bash
npx freestyle vm exec $VM_ID 'bash -s' <<'SCRIPT'
apt-get update -qq
apt-get install -y -qq docker.io
systemctl start docker
echo "Docker ready"
SCRIPT
```

### Delete all VMs

```bash
for vm_id in $(npx freestyle vm list --json | python3 -c "import sys,json; [print(v['id']) for v in json.load(sys.stdin)['vms']]"); do
    echo "Deleting $vm_id..."
    npx freestyle vm delete "$vm_id"
done
```

## Helper Scripts

See [scripts/freestyle-helpers.sh](scripts/freestyle-helpers.sh) for reusable functions.

## Known Issues

See [references/known-issues.md](references/known-issues.md) for detailed limitations and workarounds.
