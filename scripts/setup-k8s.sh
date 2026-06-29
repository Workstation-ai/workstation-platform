#!/bin/bash
# Setup Kubernetes cluster for Workstation Platform
# Supports: minikube, kind, k3s, or existing cluster

set -e

CLUSTER_TYPE=${1:-"minikube"}
NAMESPACE="workstation"

echo "Setting up Workstation Platform on: $CLUSTER_TYPE"

# Install Helm if not present
if ! command -v helm &> /dev/null; then
  echo "Installing Helm..."
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Install KEDA if not present
if ! kubectl get crd scaledobjects.keda.sh &> /dev/null; then
  echo "Installing KEDA..."
  helm repo add kedacore https://kedacore.github.io/charts
  helm repo update
  helm install keda kedacore/keda --namespace keda --create-namespace
fi

# Create workstation namespace
echo "Creating workstation namespace..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Install base chart
echo "Installing workstation base..."
helm install workstation-base ./charts/base \
  --namespace "$NAMESPACE" \
  --wait

echo ""
echo "Workstation Platform setup complete!"
echo ""
echo "Next steps:"
echo "  1. Configure cloud credentials: kubectl edit secret -n $NAMESPACE workstation-base-cloud-credentials"
echo "  2. Create a user: ./deployments/create-user.sh <username> <user-id> --desktop"
echo "  3. Check status: kubectl get all -n $NAMESPACE"
