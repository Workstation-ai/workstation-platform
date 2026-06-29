# Persistence Skill

## What problem does it solve?

Manage persistent data in Kubernetes applications. Covers PVC for block storage, S3 for object storage, and state management patterns.

## When should it be used?

- User data that survives pod restarts
- Database storage
- File uploads/documents
- Configuration state
- Backup/restore requirements

## When should NOT it be used?

- Stateless applications
- Cache data (use Redis/Memcached)
- Temporary files (use emptyDir)
- When only latest version matters (use ConfigMap)

## Decision Tree

```
Need persistence?
↓
Data type?
↓
Files/documents → PVC (ReadWriteOnce)
Shared files → PVC (ReadWriteMany) or NFS
Object storage → S3/MinIO
Database → StatefulSet + PVC
↓
Access pattern?
↓
Single pod → ReadWriteOnce
Multiple pods → ReadWriteMany or shared filesystem
Read-only → ReadOnlyMany
↓
Backup needed?
↓
Yes → Velero or cloud-native backups
No → Risk of data loss
```

## Best Practices

1. **StorageClass** - Define appropriate storage classes
2. **Resource quotas** - Limit PVC size per tenant
3. **Backup strategy** - Regular backups with Velero
4. **Monitoring** - Alert on PVC usage
5. **Cleanup** - Delete PVCs when tenants are removed

## Anti-Patterns

- Don't use hostPath (not portable, no backup)
- Don't skip storageClass (uses default, may not be appropriate)
- Don't forget to delete PVCs (orphaned storage)
- Don't store secrets in PVCs (use Secrets)
- Don't ignore PVC capacity (filling up = downtime)

## References

- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [Velero](https://velero.io/)
