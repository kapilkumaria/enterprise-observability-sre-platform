variable "project_name" {
  description = "Project name used for resource names and tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "cluster_name" {
  description = "Name of the Amazon EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes minor version used by Amazon EKS."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.cluster_version))
    error_message = "The cluster version must use a minor-version format such as 1.36."
  }
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role used by the EKS control plane."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/", var.cluster_role_arn))
    error_message = "The cluster role must be a valid IAM role ARN."
  }
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the EKS control plane."
  type        = list(string)

  validation {
    condition = (
      length(var.private_subnet_ids) >= 2 &&
      alltrue([
        for subnet_id in var.private_subnet_ids :
        can(regex("^subnet-[0-9a-f]+$", subnet_id))
      ])
    )
    error_message = "At least two valid private subnet IDs must be provided."
  }
}

variable "cluster_public_access_cidrs" {
  description = "IPv4 CIDRs allowed to access the public EKS API endpoint."
  type        = list(string)

  validation {
    condition = (
      length(var.cluster_public_access_cidrs) > 0 &&
      alltrue([
        for cidr in var.cluster_public_access_cidrs :
        can(cidrnetmask(cidr))
      ]) &&
      !contains(var.cluster_public_access_cidrs, "0.0.0.0/0")
    )
    error_message = "Provide restricted valid CIDRs; 0.0.0.0/0 is not allowed."
  }
}

variable "admin_principal_arn" {
  description = "IAM principal granted EKS cluster-administrator access."
  type        = string

  validation {
    condition = can(
      regex(
        "^arn:aws:iam::[0-9]{12}:(user|role)/",
        var.admin_principal_arn
      )
    )
    error_message = "The administrator principal must be a valid IAM user or role ARN."
  }
}

variable "control_plane_log_retention_days" {
  description = "CloudWatch retention period for EKS control-plane logs."
  type        = number
  default     = 30

  validation {
    condition = contains(
      [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365],
      var.control_plane_log_retention_days
    )
    error_message = "The log retention period must be supported by CloudWatch Logs."
  }
}

variable "pod_identity_agent_version" {
  description = "EKS-compatible version of the Pod Identity Agent add-on."
  type        = string
}

variable "vpc_cni_version" {
  description = "EKS-compatible version of the Amazon VPC CNI add-on."
  type        = string
}

variable "kube_proxy_version" {
  description = "EKS-compatible version of the kube-proxy add-on."
  type        = string
}

variable "vpc_cni_role_arn" {
  description = "ARN of the dedicated VPC CNI Pod Identity IAM role."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/", var.vpc_cni_role_arn))
    error_message = "The VPC CNI role must be a valid IAM role ARN."
  }
}

variable "node_role_arn" {
  description = "ARN of the IAM role used by EKS managed worker nodes."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/", var.node_role_arn))
    error_message = "The EKS node role must be a valid IAM role ARN."
  }
}

variable "node_group_name" {
  description = "Name of the EKS managed node group."
  type        = string
}

variable "node_group_instance_types" {
  description = "EC2 instance types used by the EKS managed node group."
  type        = list(string)

  validation {
    condition     = length(var.node_group_instance_types) > 0
    error_message = "At least one EC2 instance type must be provided."
  }
}

variable "node_group_capacity_type" {
  description = "Capacity type used by the EKS managed node group."
  type        = string

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_group_capacity_type)
    error_message = "The node-group capacity type must be ON_DEMAND or SPOT."
  }
}

variable "node_group_ami_type" {
  description = "EKS-optimized AMI type used by the managed node group."
  type        = string
}

variable "node_group_disk_size" {
  description = "Root EBS volume size in GiB for each worker node."
  type        = number

  validation {
    condition     = var.node_group_disk_size >= 20
    error_message = "The node-group disk size must be at least 20 GiB."
  }
}

variable "node_group_desired_size" {
  description = "Desired number of worker nodes."
  type        = number

  validation {
    condition     = var.node_group_desired_size >= 1
    error_message = "The desired node-group size must be at least one."
  }
}

variable "node_group_min_size" {
  description = "Minimum number of worker nodes."
  type        = number

  validation {
    condition     = var.node_group_min_size >= 1
    error_message = "The minimum node-group size must be at least one."
  }
}

variable "node_group_max_size" {
  description = "Maximum number of worker nodes."
  type        = number

  validation {
    condition     = var.node_group_max_size >= var.node_group_min_size
    error_message = "The maximum node-group size must be greater than or equal to its minimum size."
  }
}

variable "coredns_version" {
  description = "EKS-compatible version of the CoreDNS managed add-on."
  type        = string
}

variable "ebs_csi_version" {
  description = "EKS-compatible version of the Amazon EBS CSI managed add-on."
  type        = string
}

variable "ebs_csi_role_arn" {
  description = "ARN of the dedicated EBS CSI Pod Identity IAM role."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/", var.ebs_csi_role_arn))
    error_message = "The EBS CSI role must be a valid IAM role ARN."
  }
}

variable "metrics_server_version" {
  description = "EKS-compatible version of the Metrics Server managed add-on."
  type        = string
}
