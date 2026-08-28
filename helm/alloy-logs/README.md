# Grafana Alloy Kubernetes logging agents

This directory contains the Git-managed Helm values for the node-level
Grafana Alloy logging agents.

## Purpose

The `alloy-logs` release collects Kubernetes container logs and forwards
them to Loki. It is separate from the central `alloy-collector` release,
which receives OTLP traces and forwards them to Jaeger.

The two releases have intentionally different responsibilities:

- `alloy-collector` is a Deployment for centralized OTLP ingestion.
- `alloy-logs` is a DaemonSet with one logging agent per Kubernetes node.

## Log processing flow

Each Alloy logging agent performs the following flow:

1. Discover Kubernetes pods through the Kubernetes API.
2. Keep only pods scheduled on the same node as the logging agent.
3. Retrieve the selected containers' logs through the pod log API.
4. Parse Kubernetes CRI log envelopes.
5. Attach namespace, pod, container, node, application and job labels.
6. Add static cluster and environment labels.
7. Forward the processed log streams to the internal Loki gateway.

The Loki push endpoint is:

    http://loki-gateway.observability.svc.cluster.local/loki/api/v1/push

## Pod Security design

The logging agents use the Kubernetes pod log API rather than mounting
the node's `/var/log` directory. This avoids privileged access and
hostPath volumes while remaining compatible with the namespace's
Restricted Pod Security posture.

The DaemonSet applies these controls:

- Non-root UID and GID 65534
- RuntimeDefault seccomp profile
- Privilege escalation disabled
- All Linux capabilities dropped
- Read-only root filesystem
- Bounded ephemeral Alloy storage
- No host network
- No host PID namespace
- No privileged container
- No hostPath volume
- Explicit CPU and memory requests and limits
- Anonymous usage reporting disabled

## Kubernetes API access

Unlike the central trace collector, the logging agents require
Kubernetes API credentials to discover pods and retrieve their logs.

The `alloy-logs` ServiceAccount therefore mounts a token and receives a
minimal read-only ClusterRole permitting only:

- `get`, `list` and `watch` on `pods`
- `get`, `list` and `watch` on `pods/log`

The logging identity cannot read Secrets, ConfigMaps, execute commands
inside pods or access node metrics.

## Network access

Network policies permit only the relevant flows:

- Alloy logging agents to the Kubernetes API on TCP 443
- Alloy logging agents to Loki through the gateway
- Prometheus to the Alloy metrics endpoint on TCP 12345
- DNS resolution through the existing namespace DNS policy

The logging agents have no unrestricted internet egress.
