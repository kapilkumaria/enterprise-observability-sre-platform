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
