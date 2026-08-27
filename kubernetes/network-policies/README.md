# Kubernetes Network Isolation

This directory defines the baseline network-isolation model for the enterprise observability platform.

## Enforcement engine

NetworkPolicy enforcement is provided by the Amazon VPC CNI Network Policy Agent.

The feature is enabled through the Terraform-managed vpc-cni EKS add-on configuration:

    {
      "enableNetworkPolicy": "true"
    }

The agent converts Kubernetes NetworkPolicy resources into AWS-managed PolicyEndpoint resources and enforces the resulting rules on EKS Linux worker nodes.

## Default security posture

The following namespaces use default-deny ingress and egress:

- applications
- observability
- opentelemetry

Workloads receive no network access unless another policy explicitly permits the required communication.

## DNS access

All three managed namespaces may query CoreDNS over:

- UDP 53
- TCP 53

DNS traffic is restricted to pods labelled k8s-app: kube-dns in the kube-system namespace.

## Application-to-OpenTelemetry access

Application pods must explicitly opt into telemetry exporting with this label:

    observability.kapilkumaria.com/export-otlp: "true"

Only opted-in application pods may initiate OTLP traffic on:

- TCP 4317 — OTLP/gRPC
- TCP 4318 — OTLP/HTTP

Collector ingress additionally requires:

    app.kubernetes.io/component: collector

The collector accepts OTLP traffic only from appropriately labelled pods in the applications namespace.

## Kubernetes Service CIDR

The EKS cluster uses this Kubernetes Service CIDR:

    172.20.0.0/16

The OTLP egress policy includes the Service CIDR on TCP ports 4317 and 4318. During validation, the Amazon VPC CNI enforcement datapath evaluated Kubernetes Service traffic against the ClusterIP before kube-proxy translated it to the collector pod IP.

Security remains layered:

1. Only explicitly opted-in application pods receive OTLP egress permission.
2. Only TCP ports 4317 and 4318 are permitted.
3. Collector ingress accepts only opted-in pods from the applications namespace.
4. Destination pods must carry the collector component label.
5. All other ingress and egress remains denied.

## Validation

The implementation was tested with controller-managed workloads.

Validation proved:

- DNS remained available after default-deny enforcement.
- Internet egress was denied.
- Kubernetes API egress was denied.
- Authorized OTLP pod traffic succeeded.
- Authorized OTLP Service traffic succeeded.
- Unauthorized workloads could not reach the collector.
- Unapproved destination ports remained blocked.
- VPC CNI generated the expected PolicyEndpoint resources.
- Temporary validation resources were removed.
- Live policies matched the repository with zero diff.

## Future extensions

Additional least-privilege policies will be introduced as Prometheus, Grafana, Alertmanager, Loki and OpenTelemetry components are deployed.

Broad same-namespace access should not be introduced as a replacement for workload-specific policies.

## Monitoring-stack policies

The `observability` namespace uses a default-deny ingress and egress
posture. The kube-prometheus-stack receives only the traffic required
for monitoring operations.

### Internal monitoring traffic

`allow-observability-internal` permits communication between pods within
the `observability` namespace. This supports communication among
Prometheus, Alertmanager, Grafana, kube-state-metrics and the Prometheus
Operator without permitting ingress from other application namespaces.

### Kubernetes API access

`allow-observability-kubernetes-api` permits TCP 443 egress to the
Kubernetes Service CIDR and the private platform VPC CIDR. This is
required by the Prometheus Operator, kube-state-metrics, Prometheus and
Grafana sidecars for Kubernetes API discovery and reconciliation.

The rule does not permit general internet egress.

### Node and kubelet scraping

`allow-prometheus-node-scraping` permits only Prometheus pods to reach
TCP ports 9100 and 10250 inside the platform VPC:

- TCP 9100 for node-exporter
- TCP 10250 for kubelet metrics

### CoreDNS scraping

`allow-prometheus-coredns-scraping` permits only Prometheus pods to reach
CoreDNS pods in `kube-system` on TCP 9153.

### Prometheus Operator webhook

`allow-prometheus-operator-webhook` permits the private Kubernetes
control plane to reach the Prometheus Operator admission webhook on
TCP 10250.

### Existing DNS access

The existing `allow-dns-egress` policy permits TCP and UDP port 53 to
CoreDNS. All monitoring workloads remain subject to the namespace
default-deny policy.

## Dedicated node-exporter namespace

Prometheus node-exporter requires host namespaces, hostPath mounts and a
host port. These capabilities are rejected by both the Kubernetes Pod
Security Baseline and Restricted profiles.

Node-exporter is therefore isolated in the `monitoring-system` namespace.
That namespace enforces the Privileged profile while continuing to audit
and warn against the Restricted profile.

The exception does not weaken the `observability` namespace. Prometheus,
Alertmanager, Grafana, kube-state-metrics and the Prometheus Operator
continue to run under Baseline enforcement with Restricted auditing and
warnings.

The `monitoring-system-default-deny` policy isolates the namespace. The
`allow-prometheus-node-exporter-scraping` policy permits Prometheus to
reach node-exporter on TCP 9100.
