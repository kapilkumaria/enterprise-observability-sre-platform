# Kubernetes Network Isolation

This directory defines the baseline network-isolation model for the enterprise observability platform.

## Enforcement engine

NetworkPolicy enforcement is provided by the Amazon VPC CNI Network Policy Agent. The feature is enabled through the Terraform-managed `vpc-cni` EKS add-on configuration.

```json
{
  "enableNetworkPolicy": "true"
}
