# devrick Helm chart

Deploys Devrick to Kubernetes: an always-on **coordinator** (exactly one replica) and **dashboard**,
plus the RBAC, config, secrets and shared transcript volume the coordinator needs to **launch
coder/planner workers as ephemeral Jobs**, one per piece of work, and delete them when done.

```
 Jira/Slack ──► SQS ──► coordinator ──creates──► Job: coder-ats-1234-a1  (agent image, ROLE=coder)
                          │   ▲                  Job: planner-ats-9-a1   (agent image, ROLE=planner)
                          │   └─ reconciles, requeues dead workers, deletes finished ones
                          ▼
                       Postgres ◄── dashboard (read-only)           shared EFS volume ──► ~/.claude/projects in every worker
```

## Where this chart lives

Published from this repo (`charts/devrick`) by chart-releaser to `https://brightmove.github.io/helm-charts`. The
application and its images are built from https://github.com/BrightMove/devrick (`deploy/build-and-push.sh`); the
chart itself is self-contained: `values.yaml` documents every option, and `templates/` holds the manifests. Bump `version` in `Chart.yaml` on every change, or nothing is republished.

## Prerequisites

1. **Images.** `IMAGE_REPO=<your registry>/devrick deploy/build-and-push.sh` pushes `<sha>` (coordinator,
   dashboard) and `<sha>-agent` (workers). Set `image.repository` and `image.tag=<sha>`.
2. **Postgres** reachable from the cluster, with the Flyway migrations in `db/migrations` applied.
3. **EFS** with the EFS CSI driver, and a StorageClass backed by an access point with uid/gid `1000`
   (workers run as 1000 and EFS ignores `fsGroup`). Set `transcripts.storageClassName`, or bring your own
   `transcripts.existingClaim` (must be ReadWriteMany).
4. **SQS read access** for the coordinator (IRSA annotation via `coordinator.serviceAccountAnnotations`).
5. **Credentials.**
   - `claude setup-token` (run once by a human, logged in to the shared subscription) prints a one-year
     token: put it in `secrets.engine.data.CLAUDE_CODE_OAUTH_TOKEN`. All worker pods share it and its usage
     limits; `workers.roles.<role>.max` caps concurrency for that reason.
   - `GH_TOKEN` is the PAT git and `gh` use inside worker pods (repo, workflow scopes).

## Install / upgrade

Keep real credentials out of git: put them in a private values file (or use `secrets.*.existingSecret`).

```
helm repo add brightmove https://brightmove.github.io/helm-charts && helm repo update
helm upgrade --install devrick brightmove/devrick --version <chart-version> -n devrick -f my-values.yaml
```

Check the rendered manifests before installing (offline, no cluster contact):

```
helm lint brightmove/devrick --version <chart-version> -f my-values.yaml
helm template devrick brightmove/devrick --version <chart-version> -f my-values.yaml
```

## Things to know

- **One coordinator, by design.** `replicas: 1` with `Recreate`, so a rollout never overlaps two coordinators.
  Worker Job names are deterministic (`devrick-<role>-<ticket>-a<attempt>`), a second line of defense
  against double-launching.
- **Workers are not in this chart's workloads.** They are created at runtime from the coordinator's `WORKER_*`
  environment, which this chart renders from `workers.*`. Change `workers.roles` and upgrade to change caps,
  resources and timeouts.
- **Adding a role** (a new archetype in the code) needs an entry under `workers.roles` for its limits; the
  image already contains it.
- **Rotating the Claude token.** When it expires, workers raise the usual "needs re-authentication" Slack
  alert and the coordinator stops launching Claude workers (it falls back to Cursor when configured). Run
  `claude setup-token` again, update the Secret, and reply in the alert thread.
- **Nothing here is verified against a live cluster.** It was written and unit-tested for the Java side only.
  Run `helm lint` / `helm template` first.
