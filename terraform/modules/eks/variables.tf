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
