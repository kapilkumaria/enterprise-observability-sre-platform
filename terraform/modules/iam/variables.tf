variable "project_name" {
  description = "Project name used for IAM role names and tags."
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
