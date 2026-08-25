# Enterprise Observability and SRE Platform

[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazonaws)](https://aws.amazon.com/)
[![Kubernetes](https://img.shields.io/badge/Platform-Kubernetes-326CE5?logo=kubernetes)](https://kubernetes.io/)
[![OpenTelemetry](https://img.shields.io/badge/Telemetry-OpenTelemetry-000000?logo=opentelemetry)](https://opentelemetry.io/)
[![Prometheus](https://img.shields.io/badge/Metrics-Prometheus-E6522C?logo=prometheus)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Visualization-Grafana-F46800?logo=grafana)](https://grafana.com/)

## Project Overview

This project implements a production-oriented observability and Site
Reliability Engineering platform on Amazon EKS.

It provides unified collection, storage, visualization and correlation of
metrics, logs and distributed traces using OpenTelemetry, Prometheus,
Grafana, Loki, Tempo and Alertmanager.

The platform extends traditional monitoring with SRE capabilities including
service-level indicators, service-level objectives, error budgets,
multi-window burn-rate alerts, synthetic monitoring, incident response,
runbooks and controlled failure validation.

## Business Problem

Cloud-native applications generate telemetry across infrastructure,
Kubernetes and multiple application services. When metrics, logs and traces
are fragmented, engineers struggle to detect customer impact, determine root
cause and restore service quickly.

This platform establishes a standardized observability and reliability
engineering model that enables teams to:

- Detect service degradation before customers report it
- Correlate metrics, logs and traces
- Measure reliability using SLIs and SLOs
- Track and manage error-budget consumption
- Reduce alert fatigue with actionable alerts
- Troubleshoot distributed applications efficiently
- Validate reliability through controlled failure scenarios
- Document incidents using blameless postmortems

## Core Capabilities

- Amazon EKS provisioned using Terraform
- Private worker nodes distributed across Availability Zones
- GitOps reconciliation using Argo CD
- Kubernetes and application metrics using Prometheus
- Centralized logs using Loki and Grafana Alloy
- Distributed traces using Tempo
- Vendor-neutral telemetry using OpenTelemetry
- Reproducible Grafana data sources and dashboards
- ServiceMonitor and PrometheusRule resources
- SLIs, SLOs and error budgets
- Multi-window burn-rate alerting
- Synthetic monitoring using Blackbox Exporter
- Alert routing using Alertmanager
- Load and reliability testing using k6
- Secure AWS access using workload identity
- CI validation and security scanning
- Incident runbooks and postmortem documentation
- Full infrastructure rebuild and recovery validation

## Technology Stack

| Area                    | Technology                  |
| ----------------------- | --------------------------- |
| Cloud                   | AWS                         |
| Infrastructure as Code  | Terraform                   |
| Container orchestration | Amazon EKS / Kubernetes     |
| GitOps                  | Argo CD                     |
| Packaging               | Helm                        |
| Telemetry standard      | OpenTelemetry               |
| Metrics                 | Prometheus                  |
| Visualization           | Grafana                     |
| Logs                    | Loki                        |
| Log collection          | Grafana Alloy               |
| Traces                  | Tempo                       |
| Alerting                | Alertmanager                |
| SLO management          | Sloth                       |
| Synthetic monitoring    | Blackbox Exporter           |
| Load testing            | k6                          |
| Object storage          | Amazon S3                   |
| CI and quality gates    | GitHub Actions              |
| Security scanning       | Trivy, Checkov and Gitleaks |

## Target Architecture

The platform follows this telemetry flow:

```text
Users and synthetic probes
            |
            v
Instrumented microservices
            |
            v
OpenTelemetry Collector
       /         |         \
      v          v          v
Prometheus      Loki       Tempo
      \          |          /
       \         |         /
                Grafana
                  |
                  v
       SLOs, error budgets and alerts
```
## Repository Structure

```
.
├── applications/       # Instrumented demonstration services
├── argocd/             # Argo CD bootstrap and application definitions
├── diagrams/           # Architecture diagrams
├── docs/               # ADRs, runbooks and incident documentation
├── gitops/             # Desired state for platform and applications
├── helm/               # Project-owned Helm values and charts
├── kubernetes/         # Monitoring rules, dashboards and policies
├── load-testing/       # k6 performance and reliability tests
├── opentelemetry/      # Collector and instrumentation configuration
├── scripts/            # Validation and operational automation
├── terraform/          # AWS infrastructure and reusable modules
└── tests/               # Infrastructure and configuration tests
```
## Environments

The portfolio implementation initially deploys a reproducible development
environment:
```
AWS region:       us-east-1
EKS cluster:      enterprise-observability-dev
Kubernetes:       1.36
Environment:      dev
```
Production architecture considerations, high availability, multi-cluster
operation and disaster recovery are documented separately.

## Project Status

Project implementation started on August 25, 2026.

Current stage:
```
Phase 5 — Amazon EKS control-plane foundation
```
## Documentation

Detailed documentation will be maintained under docs/, including:

- Architecture
- Implementation
- Observability strategy
- SLI and SLO design
- Alerting strategy
- Security
- Disaster recovery
- Troubleshooting
- Operational runbooks
- Incident postmortems

## Author

### Kapil Kumaria

Senior DevOps & Platform Engineer
Calgary, Alberta, Canada

Portfolio: kapilkumaria.com
