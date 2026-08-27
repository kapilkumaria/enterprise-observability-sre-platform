# kube-prometheus-stack

This directory contains the platform-owned values for the pinned
`kube-prometheus-stack` Helm chart.

## Version

The authoritative chart and application versions are recorded in:

- `helm/chart-versions.yaml`
- `helm/kube-prometheus-stack/chart.yaml`

## Platform configuration

The values configure:

- Prometheus Operator and monitoring CRDs
- Prometheus with seven-day retention
- Persistent Prometheus storage on `gp3-encrypted`
- Alertmanager with persistent storage
- Grafana with persistent storage
- Grafana credentials supplied through an existing Kubernetes Secret
- kube-state-metrics
- Prometheus node-exporter
- Kubernetes API server, kubelet and CoreDNS monitoring
- Resource requests and limits for all rendered workload containers
- Non-root execution and hardened container security contexts
- ClusterIP-only Services
- No public ingress or external LoadBalancer Services

EKS-managed control-plane components that do not expose directly
scrapable in-cluster endpoints are disabled:

- etcd
- kube-controller-manager
- kube-scheduler
- kube-proxy

## Grafana credentials

The chart expects this runtime Secret in the `observability` namespace:

- Secret: `grafana-admin-credentials`
- Username key: `admin-user`
- Password key: `admin-password`

The Secret is intentionally not stored in Git.

## Node-exporter security exception

Prometheus node-exporter requires read-only access to host operating-system
metrics. The DaemonSet therefore uses:

- `hostNetwork: true`
- `hostPID: true`
- Read-only hostPath mounts for `/proc`, `/sys` and `/`

This causes an expected warning against the Kubernetes Pod Security
Restricted profile.

The exception is intentionally limited to the node-exporter DaemonSet.
Its container remains hardened with:

- Non-root UID and GID 65534
- Read-only root filesystem
- Privilege escalation disabled
- All Linux capabilities dropped
- RuntimeDefault seccomp
- Read-only host mounts
- Explicit CPU and memory requests and limits

The `observability` namespace enforces the Pod Security Baseline profile
and audits/warns against Restricted. This permits the required host
metrics collector while still surfacing the exception for review.

## Storage

| Component | Storage class | Capacity | Purpose |
|---|---|---:|---|
| Prometheus | `gp3-encrypted` | 30 GiB | Metrics and time-series data |
| Alertmanager | `gp3-encrypted` | 5 GiB | Alert state and silences |
| Grafana | `gp3-encrypted` | 5 GiB | Grafana state and plugins |

The Grafana `init-chown-data` container is disabled. Kubernetes applies
the configured pod `fsGroup` to the persistent volume instead of running
a root ownership-changing init container.

## Validation

Before installation, the chart is checked for:

- Successful Helm rendering
- Kubernetes API schema compatibility
- Complete container requests and limits
- Hardened pod and container security contexts
- Explicit non-latest image versions
- Private Services only
- No plaintext credentials
- Expected node-exporter Pod Security exception only
