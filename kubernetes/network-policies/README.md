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
