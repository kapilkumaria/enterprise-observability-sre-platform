# Jaeger tracing backend

This directory contains the Git-managed Helm values for the Jaeger v2
tracing backend.

## Purpose

Jaeger receives, stores and queries distributed traces. The initial
development deployment uses the official Jaeger all-in-one chart and
runs in the `opentelemetry` namespace.

The internal ClusterIP Service exposes:

- TCP 4317 for OTLP/gRPC ingestion
- TCP 4318 for OTLP/HTTP ingestion
- TCP 16686 for the Jaeger query API and UI
- TCP 8888 for internal Prometheus metrics

No Jaeger port is exposed directly to the public internet.

## Storage decision

The development environment intentionally uses Jaeger's default
in-memory storage. This keeps the portfolio environment inexpensive and
quick to rebuild.

In-memory storage is ephemeral. Traces disappear when the Jaeger pod is
recreated or restarted. A production deployment should use durable
external storage such as Elasticsearch or Cassandra and should separate
collector and query responsibilities for independent scaling.

## Security controls

The deployment applies the following controls:

- Non-root UID and GID 10001
- RuntimeDefault seccomp profile
- Privilege escalation disabled
- All Linux capabilities dropped
- Read-only container root filesystem
- Bounded ephemeral `/tmp` volume
- Kubernetes ServiceAccount token automount disabled
- Explicit CPU and memory requests and limits
- ClusterIP-only Service
- Default-deny network-policy integration

## Telemetry flow

Applications will export OTLP telemetry to Grafana Alloy. Alloy will
process and forward traces to Jaeger. Grafana will query Jaeger through
its internal query endpoint, and Prometheus will scrape Jaeger's
internal metrics endpoint.

The Alloy layer is implemented in the next platform phase.
