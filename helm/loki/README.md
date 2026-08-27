# Loki

This directory contains the Git-managed Helm values for the platform's
centralized log storage service.

## Version

- Helm chart: `grafana/loki` `7.3.0`
- Loki application: `3.6.11`
- Deployment mode: `SingleBinary`

The application version is taken from the rendered chart metadata and
container image. It is intentionally documented as `3.6.11`, which is
the application version packaged by chart `7.3.0`.

## Architecture

The development environment runs one Loki SingleBinary StatefulSet and
one internal NGINX gateway Deployment in the `observability` namespace.

The gateway exposes Loki only through a Kubernetes ClusterIP Service.
No public ingress or load balancer is created.

Loki stores chunks, indexes, ruler data and compactor state on an
encrypted `gp3-encrypted` persistent volume.

## Storage and retention

- Storage engine: TSDB
- Schema: v13
- Object store: local filesystem
- Persistent capacity: 30 GiB
- Storage class: `gp3-encrypted`
- Retention: 7 days
- PVC deletion policy: Retain
- PVC scale-down policy: Retain

The compactor performs retention processing and stores deletion-request
state on the same persistent filesystem.

## Security

The Loki and gateway containers run as non-root users with:

- Read-only root filesystems
- Privilege escalation disabled
- All Linux capabilities dropped
- RuntimeDefault seccomp
- Explicit CPU and memory requests and limits

Writable paths are limited to chart-managed `emptyDir` volumes and the
Loki persistent data volume.

Loki rule discovery is disabled, so the runtime does not require
ClusterRole, ClusterRoleBinding, Role or RoleBinding resources.
Kubernetes API service-account token automounting is also disabled.

Authentication is disabled because Loki is reachable only through the
internal ClusterIP gateway and the platform currently operates as a
single trusted tenant. NetworkPolicy and namespace isolation provide
the network boundary.

## Monitoring

The chart creates:

- Prometheus Operator ServiceMonitor resources
- Grafana dashboard ConfigMaps

Prometheus discovers the ServiceMonitors through the platform's
namespace-scoped monitoring selector. Grafana's dashboard sidecar
discovers ConfigMaps labeled `grafana_dashboard=1`.

## Capacity choices

The optional chunks and results Memcached caches are disabled. Their
chart defaults are oversized for this development cluster, particularly
the default 8 GiB chunks cache.

The Loki canary and Helm test pod are also disabled. End-to-end log
delivery will instead be validated after Grafana Alloy is deployed.

## Production evolution

The SingleBinary filesystem design is appropriate for this portfolio
and development environment, but it is not the target architecture for
large-scale production ingestion.

A production evolution would use:

- Amazon S3 object storage
- IAM Roles for Service Accounts or EKS Pod Identity
- Simple Scalable or Distributed deployment mode
- Multiple replicas across Availability Zones
- Pod disruption budgets
- Autoscaling and query caching
- Tenant authentication and authorization
- Backup, disaster-recovery and capacity procedures
