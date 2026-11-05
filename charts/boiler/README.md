# Boiler Chart

The Helm chart for deploying the Boiler application.

Internal use only.

## Persistence

Uploaded files live in `BOILER_DATA_DIR` (`dataDir`, default `/app/data`). That path is an `emptyDir` until persistence is turned on, so files are lost when the pod restarts.

Nothing is persisted for existing installs. To keep uploads across restarts, set:

```yaml
persistence:
  enabled: true
  size: 5Gi
  # storageClass: gp3        # optional; omit to use the cluster default StorageClass
  accessModes:
    - ReadWriteOnce
  # existingClaim: boiler-data  # optional; use this claim and do not create one
```

`ReadWriteOnce` mounts on a single node. With that access mode the Deployment uses `Recreate` and `replicaCount` must be 1, so a rollout does not start a second pod against the same claim. For more than one replica, use a `ReadWriteMany` storage class and set `accessModes` to match (including when `existingClaim` points at an existing volume).

The chart-managed claim is annotated `helm.sh/resource-policy: keep`, so uninstalling the release or turning `persistence.enabled` back off does not delete the volume. `size` is the request used when the claim is created; changing it later does not resize a claim that already exists.

## Image

The container image is `brightmove/<dockerImageName>:<tag>`. The tag defaults to `appVersion` in `Chart.yaml`. Set `image.tag` to override it without editing the chart.

`imagePullPolicy` is `Always` when the resolved tag is `latest`, and `IfNotPresent` for any other tag. `image.tag: latest` keeps the previous always-pull behavior. Set `image.pullPolicy` to force a policy.

A versioned tag changes the pod template on each release, so the Deployment rolls. Pushing a new `latest` image does not, because the pod spec is unchanged.
