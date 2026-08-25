variable "aws_region" {
  description = "AWS region used by the development environment."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource names and tags."
  type        = string
  default     = "enterprise-observability"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "Name of the Amazon EKS cluster."
  type        = string
  default     = "enterprise-observability-dev"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR assigned to the development VPC."
  type        = string
  default     = "10.60.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs assigned to public subnets."
  type        = list(string)

  default = [
    "10.60.0.0/24",
    "10.60.1.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDRs assigned to private subnets."
  type        = list(string)

  default = [
    "10.60.10.0/24",
    "10.60.11.0/24"
  ]
}

variable "flow_log_retention_days" {
  description = "CloudWatch retention period for VPC Flow Logs."
  type        = number
  default     = 30
}

variable "cluster_version" {
  description = "Kubernetes minor version used by Amazon EKS."
  type        = string
  default     = "1.36"
}

variable "cluster_public_access_cidrs" {
  description = "IPv4 CIDRs allowed to reach the public EKS API endpoint."
  type        = list(string)

  validation {
    condition = (
      length(var.cluster_public_access_cidrs) > 0 &&
      !contains(var.cluster_public_access_cidrs, "0.0.0.0/0")
    )
    error_message = "Restricted EKS API access CIDRs must be provided."
  }
}

variable "control_plane_log_retention_days" {
  description = "CloudWatch retention period for EKS control-plane logs."
  type        = number
  default     = 30
}

variable "pod_identity_agent_version" {
  description = "EKS Pod Identity Agent version compatible with EKS 1.36."
  type        = string
  default     = "v1.3.10-eksbuild.3"
}

variable "vpc_cni_version" {
  description = "Amazon VPC CNI version compatible with EKS 1.36."
  type        = string
  default     = "v1.22.4-eksbuild.3"
}

variable "kube_proxy_version" {
  description = "kube-proxy version compatible with EKS 1.36."
  type        = string
  default     = "v1.36.0-eksbuild.14"
}

variable "node_group_name" {
  description = "Name of the development EKS managed node group."
  type        = string
  default     = "system"
}

variable "node_group_instance_types" {
  description = "EC2 instance types used by development worker nodes."
  type        = list(string)
  default     = ["t3.large"]
}

variable "node_group_capacity_type" {
  description = "Capacity type used by development worker nodes."
  type        = string
  default     = "ON_DEMAND"
}

variable "node_group_ami_type" {
  description = "EKS-optimized AMI used by development worker nodes."
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "node_group_disk_size" {
  description = "Root EBS volume size in GiB for development worker nodes."
  type        = number
  default     = 50
}

variable "node_group_desired_size" {
  description = "Desired number of development worker nodes."
  type        = number
  default     = 3
}

variable "node_group_min_size" {
  description = "Minimum number of development worker nodes."
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum number of development worker nodes."
  type        = number
  default     = 4
}

variable "coredns_version" {
  description = "CoreDNS version compatible with EKS 1.36."
  type        = string
  default     = "v1.14.3-eksbuild.3"
}

variable "ebs_csi_version" {
  description = "Amazon EBS CSI Driver version compatible with EKS 1.36."
  type        = string
  default     = "v1.64.0-eksbuild.1"
}
