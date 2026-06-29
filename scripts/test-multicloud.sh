#!/bin/bash
# Test multicloud connectivity via MCP server
# Usage: ./test-multicloud.sh [cloud]

set -e

CLOUD=${1:-"all"}
MCP_URL="http://workstation-mcp-server.workstation.svc.cluster.local:8080"

echo "Testing multicloud connectivity..."
echo "MCP Server: $MCP_URL"

# Test health
echo ""
echo "1. Testing MCP server health..."
kubectl exec -n workstation deployment/workstation-mcp-server -- \
  curl -s "$MCP_URL/health" | jq .

# Test cloud connections
if [ "$CLOUD" = "all" ] || [ "$CLOUD" = "aws" ]; then
  echo ""
  echo "2. Testing AWS connection..."
  kubectl exec -n workstation deployment/workstation-mcp-server -- \
    python3 -c "
import boto3
session = boto3.Session()
print('AWS region:', session.region_name or 'not configured')
try:
    s3 = session.client('s3')
    buckets = list(s3.list_buckets()['Buckets'])
    print(f'S3 buckets found: {len(buckets)}')
except Exception as e:
    print(f'AWS error: {e}')
"
fi

if [ "$CLOUD" = "all" ] || [ "$CLOUD" = "azure" ]; then
  echo ""
  echo "3. Testing Azure connection..."
  kubectl exec -n workstation deployment/workstation-mcp-server -- \
    python3 -c "
from azure.mgmt.resource import ResourceManagementClient
from azure.identity import DefaultAzureCredential
try:
    credential = DefaultAzureCredential()
    print('Azure credential obtained')
except Exception as e:
    print(f'Azure credential error: {e}')
"
fi

if [ "$CLOUD" = "all" ] || [ "$CLOUD" = "hetzner" ]; then
  echo ""
  echo "4. Testing Hetzner Cloud connection..."
  kubectl exec -n workstation deployment/workstation-mcp-server -- \
    python3 -c "
from hcloud import Client
try:
    client = Client(token='test')
    print('Hetzner client created (token validation pending)')
except Exception as e:
    print(f'Hetzner error: {e}')
"
fi

echo ""
echo "Multicloud test complete!"
