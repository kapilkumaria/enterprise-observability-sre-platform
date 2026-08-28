# Grafana Alloy collector

This directory contains the Git-managed Helm values for the central
Grafana Alloy OpenTelemetry collector.

## Purpose

The collector receives OTLP traces from explicitly authorized
application workloads and forwards those traces to the Jaeger backend.

The trace flow is:

1. An instrumented application exports OTLP.
2. Alloy receives OTLP/gRPC on TCP 4317 or OTLP/HTTP on TCP 4318.
3. The memory limiter protects the collector from memory exhaustion.
4. The batch processor groups spans for efficient export.
5. Alloy exports traces to Jaeger using OTLP/gRPC.
6. Grafana queries the stored traces from Jaeger.

## Deployment model

The central collector runs as a single Kubernetes Deployment in the
`opentelemetry` namespace.

This deployment is intentionally separate from the future node-level
Alloy logging agents. The logging agents will run as a DaemonSet and
will forward Kubernetes container logs to Loki.

## Security controls

The collector applies the following controls:

- Non-root UID and GID 65534
- RuntimeDefault seccomp profile
- Privilege escalation disabled
- All Linux capabilities dropped
- Read-only root filesystem
- Bounded ephemeral storage at `/tmp/alloy`
- ServiceAccount token automount disabled
- No RBAC, ClusterRole or ClusterRoleBinding
- No Alloy PodLogs CRD
- Explicit CPU and memory requests and limits
- ClusterIP-only Service
- Anonymous usage reporting disabled
- Default-deny network-policy integration

The collector does not use Kubernetes service discovery and therefore
does not require Kubernetes API credentials or RBAC permissions.

## Network access

Application workloads must carry this label before they can export
OTLP:

    observability.kapilkumaria.com/export-otlp: "true"

The Alloy collector pod carries:

    app.kubernetes.io/component: collector

Network policies allow only these relevant flows:

- Authorized application pods to Alloy on TCP 4317 and TCP 4318
- Alloy to Jaeger on TCP 4317
- Prometheus to Alloy on TCP 12345

The Alloy UI and metrics endpoint are not exposed publicly.

## Scaling evolution

The development environment uses one replica. A production environment
could use multiple replicas behind the ClusterIP Service, add a
PodDisruptionBudget, and enable autoscaling based on CPU, memory or
collector queue pressure.
