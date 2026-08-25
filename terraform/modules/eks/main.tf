locals {
  name_prefix = "${var.project_name}-${var.environment}"

  control_plane_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}

resource "aws_kms_key" "eks_secrets" {
  description             = "KMS key for ${var.cluster_name} Kubernetes Secrets encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  multi_region            = false

  tags = {
    Name        = "${local.name_prefix}-eks-secrets"
    Purpose     = "EKS Kubernetes Secrets encryption"
    ClusterName = var.cluster_name
  }
}

resource "aws_kms_alias" "eks_secrets" {
  name          = "alias/${local.name_prefix}-eks-secrets"
  target_key_id = aws_kms_key.eks_secrets.key_id
}

resource "aws_cloudwatch_log_group" "eks_control_plane" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.control_plane_log_retention_days

  tags = {
    Name        = "${local.name_prefix}-eks-control-plane-logs"
    Purpose     = "EKS control-plane observability"
    ClusterName = var.cluster_name
  }
}

resource "aws_eks_cluster" "this" {
  name                          = var.cluster_name
  role_arn                      = var.cluster_role_arn
  version                       = var.cluster_version
  bootstrap_self_managed_addons = false

  enabled_cluster_log_types = local.control_plane_log_types

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_secrets.arn
    }

    resources = ["secrets"]
  }

  upgrade_policy {
    support_type = "STANDARD"
  }

  vpc_config {
    subnet_ids = var.private_subnet_ids

    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.cluster_public_access_cidrs
  }

  depends_on = [
    aws_cloudwatch_log_group.eks_control_plane
  ]

  tags = {
    Name        = var.cluster_name
    ClusterName = var.cluster_name
    Purpose     = "Enterprise observability platform"
  }
}

resource "aws_eks_access_entry" "administrator" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.admin_principal_arn
  type          = "STANDARD"

  tags = {
    Name        = "${local.name_prefix}-administrator-access"
    Purpose     = "EKS cluster administration"
    ClusterName = var.cluster_name
  }
}

resource "aws_eks_access_policy_association" "administrator" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_eks_access_entry.administrator.principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
