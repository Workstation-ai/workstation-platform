# KEDA Skill

## What problem does it solve?

Scale Kubernetes workloads based on events (queue length, CPU, memory, custom metrics) rather than just resource utilization. Enables serverless-like scaling for any workload.

## When should it be used?

- Workloads with variable traffic patterns
- Queue-based processing (jobs, tasks)
- Event-driven architectures
- Cost optimization (scale to zero)
- Custom metrics scaling (API requests, etc.)

## When should NOT it be used?

- Steady-state workloads (HPA is simpler)
- When scaling latency is critical (KEDA has polling intervals)
- Simple CPU/memory scaling (HPA suffices)
- When KEDA operator overhead is not justified

## Decision Tree

```
Need autoscaling?
↓
Scaling trigger?
↓
CPU/Memory → HPA (simpler)
Queue length → KEDA with queue scaler
Custom metrics → KEDA with prometheus scaler
Cron schedule → KEDA with cron scaler
↓
Scale to zero needed?
↓
Yes → KEDA (HPA can't scale to zero)
No → HPA might be sufficient
↓
Multiple triggers?
↓
Yes → KEDA (supports multiple triggers)
No → Single trigger? HPA or KEDA
```

## Best Practices

1. **Start conservative** - Low minReplicaCount, gradual increase
2. **Set cooldownPeriod** - Prevent flapping
3. **Use TriggerAuthentication** - Don't hardcode credentials
4. **Monitor scaling** - Track scaling events and latency
5. **Test under load** - Verify scaling behavior

## Anti-Patterns

- Don't use KEDA for simple CPU scaling (HPA is simpler)
- Don't set pollingInterval too low (resource waste)
- Don't skip cooldownPeriod (scaling flapping)
- Don't hardcode credentials in ScaledObject
- Don't ignore KEDA operator resource usage

## References

- [KEDA Documentation](https://keda.sh/docs/)
- [Supported Scalers](https://keda.sh/docs/latest/scalers/)
- [TriggerAuthentications](https://keda.sh/docs/latest/concepts/authentication/)
