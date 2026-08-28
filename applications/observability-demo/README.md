# Observability Demo

The observability demo is a purpose-built FastAPI service used to
validate the enterprise observability platform.

## Signals

The service produces three telemetry signals:

- Structured JSON application and request logs for Alloy and Loki
- Prometheus RED metrics at `/metrics`
- OpenTelemetry traces exported over OTLP/HTTP to Alloy

Application logs include active OpenTelemetry trace and span identifiers
so an operator can move from a log entry to the corresponding trace.

## Endpoints

| Endpoint | Purpose |
| --- | --- |
| `/` | Normal successful request |
| `/work` | Simulated processing with a custom child span |
| `/slow?delay=0.5` | Controlled request latency |
| `/error` | Controlled HTTP 500 response |
| `/metrics` | Prometheus metrics |
| `/healthz` | Kubernetes liveness |
| `/readyz` | Kubernetes readiness |

## Security

The container:

- Runs as non-root UID and GID 10001
- Uses a pinned Python base-image digest
- Does not require a Kubernetes ServiceAccount token
- Writes application logs only to standard output
- Does not require a writable application filesystem
- Exposes only TCP port 8080
- Uses explicit, pinned Python dependencies

Kubernetes applies the remaining controls, including a read-only root
filesystem, RuntimeDefault seccomp, dropped capabilities and disabled
privilege escalation.
