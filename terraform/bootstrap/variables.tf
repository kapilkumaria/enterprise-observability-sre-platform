variable "aws_region" {
  description = "AWS region in which the Terraform state bucket is created."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "The AWS region must use a valid format such as us-east-1."
  }
}

variable "project_name" {
  description = "Project name used for resource tags."
  type        = string
  default     = "enterprise-observability-sre-platform"
}

variable "environment" {
  description = "Environment associated with the bootstrap resources."
  type        = string
  default     = "shared"
}

variable "state_bucket_prefix" {
  description = "Short prefix used to construct the globally unique state bucket name."
  type        = string
  default     = "eosre-tfstate"

  validation {
    condition = (
      length(var.state_bucket_prefix) >= 3 &&
      length(var.state_bucket_prefix) <= 30 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.state_bucket_prefix))
    )
    error_message = "The bucket prefix must contain 3-30 lowercase letters, numbers or hyphens."
  }
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days to retain noncurrent Terraform state object versions."
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_version_expiration_days >= 30
    error_message = "Noncurrent state versions must be retained for at least 30 days."
  }
}
