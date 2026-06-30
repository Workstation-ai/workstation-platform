# Popeye Cluster Diagnostics
#
# Live cluster scanner that reports misconfigurations,
# wasted resources, and potential health issues.
#
# What it checks:
#   - Pod health (restarts, OOMKilled, resource limits)
#   - Service endpoints (missing selectors, dangling services)
#   - RBAC permissions (overly permissive bindings)
#   - Resource utilization (CPU/memory requests vs limits)
#   - Network policies (unprotected namespaces)
#   - Storage (PVC binding, orphaned volumes)
#   - Container images (latest tag, image pull policies)
#
# Install:
#   ./deployments/popeye/deploy.sh
#
# Uninstall:
#   ./deployments/popeye/uninstall.sh
#
# Run scan:
#   kubectl exec -n popeye deploy/popeye -- popeye -o stdout
#
# Scan specific namespace:
#   kubectl exec -n popeye deploy/popeye -- popeye -n desktop-guac -o stdout
#
# Output formats: stdout, yaml, json, html
#
# Tips:
#   - Run after deploying workloads to catch issues early
#   - Schedule as CronJob for continuous monitoring
#   - Pipe to file: kubectl exec ... -- popeye -o yaml > report.yaml
