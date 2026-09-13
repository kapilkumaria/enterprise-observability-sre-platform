# Observability Helm Dependencies

This directory stores repository-controlled Helm values for the enterprise
observability and SRE platform.

## Dependency model

| Sync wave | Component                    | Purpose                                                     |
| --------: | ---------------------------- | ----------------------------------------------------------- |
|        30 | kube-prometheus-stack        | Prometheus Operator, Prometheus, Alertmanager and Grafana   |
|        40 | Loki                         | Centralized log storage and querying                        |
|        50 | Jaeger v2                    | Distributed trace storage, querying and trace visualization |
|        60 | Grafana Alloy collector      | OTLP ingestion, processing and delivery to Jaeger           |
|        70 | Grafana Alloy logging agents | Kubernetes log collection and delivery to Loki              |

## Dependency reasoning

The kube-prometheus-stack is installed first because it provides the
Prometheus Operator and the custom resource definitions required by
`ServiceMonitor` and `PrometheusRule` resources.

Loki is installed before the Alloy logging agents because the agents forward
collected Kubernetes container logs to the Loki gateway.

Jaeger is installed before the central Alloy collector because Alloy forwards
processed OTLP traces to the Jaeger ingestion endpoint.

The Alloy collector is installed after Jaeger so its trace-export destination
is available before the collector starts.

The Alloy logging agents are installed after Loki and the central collector.
Loki is therefore available before the agents begin forwarding Kubernetes
container logs.

## Values management

Each Helm release has a repository-controlled values directory:

- `helm/kube-prometheus-stack`
- `helm/loki`
- `helm/alloy-logs`
- `helm/alloy`
- `helm/jaeger`

Pinned chart versions, application versions, repositories, namespaces and
Argo CD synchronization waves are maintained in
[`helm/chart-versions.yaml`](chart-versions.yaml).

## Argo CD integration

Argo CD uses multiple application sources where required:

1. A pinned external Helm chart.
2. This Git repository as the source of environment-specific values.

The platform deploys two distinct Grafana Alloy roles:

- `alloy-logs` runs as a DaemonSet and collects Kubernetes container logs.
- `alloy-collector` runs as a Deployment and receives application OTLP
  telemetry before forwarding traces to Jaeger.

No credentials or generated secrets are stored in these directories.
Runtime secrets are created or managed separately from the repository.
