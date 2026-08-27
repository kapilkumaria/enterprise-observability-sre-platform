# Observability Helm Dependencies

This directory stores repository-controlled Helm values for the enterprise observability and SRE platform.

## Dependency model

| Sync wave | Component | Purpose |
|---:|---|---|
| 30 | kube-prometheus-stack | Prometheus Operator, Prometheus, Alertmanager and Grafana |
| 40 | Loki | Centralized log storage and querying |
| 45 | Grafana Alloy | Kubernetes log collection and delivery to Loki |
| 50 | Jaeger v2 | Distributed trace storage, querying and trace UI |
| 60 | OpenTelemetry Collector | Vendor-neutral telemetry ingestion, processing and export |

## Dependency reasoning

The kube-prometheus-stack is installed first because it provides the Prometheus Operator CRDs used by ServiceMonitor and PrometheusRule resources.

Loki is installed before Alloy because Alloy exports collected Kubernetes logs to Loki.

Jaeger is installed before the OpenTelemetry Collector because the collector exports processed traces to the Jaeger OTLP endpoint.

The OpenTelemetry Collector is installed before the demonstration application so that the application has a valid OTLP destination when it starts.

## Values management

Each component has a dedicated values directory:

- `helm/kube-prometheus-stack`
- `helm/loki`
- `helm/alloy`
- `helm/jaeger`
- `helm/opentelemetry-collector`

Argo CD will use multiple sources:

1. A pinned external Helm chart.
2. This Git repository as the source of the environment-specific values file.

No credentials or generated secrets are stored in these directories.
