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

## Grafana plugin runtime

Grafana keeps its container root filesystem read-only. Grafana 13
bundled backend plugins, including Prometheus, Loki, Tempo and Jaeger,
require writable temporary storage during plugin startup.

A dedicated ephemeral `emptyDir` is mounted at `/tmp`. This allows
backend plugins to create temporary handshake files without weakening
the container-level `readOnlyRootFilesystem` control. No credentials or
persistent application data are stored in this temporary volume.

## Grafana datasources

Grafana provisions its datasources declaratively through the
kube-prometheus-stack datasource ConfigMap:

- Prometheus is the default metrics datasource.
- Alertmanager provides alert-state integration.
- Loki provides centralized LogQL access through the internal
  `loki-gateway` ClusterIP Service.
- Jaeger provides distributed-trace querying through the internal
  `jaeger` ClusterIP Service in the `opentelemetry` namespace.

The Loki and Jaeger datasources are read-only from Grafana's
provisioning perspective. Neither backend is exposed through an
external service.

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

Node-exporter runs in the dedicated `monitoring-system` namespace. That
namespace enforces the Pod Security Privileged profile because the
collector requires host namespaces, hostPath mounts and a host port. It
continues to audit and warn against the Restricted profile.

The remaining monitoring components stay in `observability`, which
continues to enforce the Baseline profile and audit/warn against
Restricted. The node-exporter ServiceMonitor is colocated with its
Service in `monitoring-system`.

Prometheus discovers ServiceMonitors only in namespaces whose platform
tier is `observability` or `host-monitoring`. This includes the dedicated
node-exporter namespace without enabling unrestricted cluster-wide
ServiceMonitor discovery.

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

## kube-system access

The Argo CD `observability-platform` AppProject explicitly permits the
`kube-system` destination because kube-prometheus-stack creates metrics
discovery resources for EKS system components there.

The current configuration uses this access for CoreDNS monitoring. The
chart creates a metrics Service that selects the existing EKS CoreDNS
pods and exposes their TCP 9153 metrics endpoint to Prometheus.

The AppProject does not use a wildcard destination. Each permitted
namespace is listed explicitly.
