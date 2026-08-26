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

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = var.pod_identity_agent_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = {
    Name        = "${local.name_prefix}-pod-identity-agent"
    Purpose     = "EKS Pod Identity credentials"
    ClusterName = var.cluster_name
  }
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "vpc-cni"
  addon_version = var.vpc_cni_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  configuration_values = jsonencode({
    enableNetworkPolicy = "true"
  })

  pod_identity_association {
    role_arn        = var.vpc_cni_role_arn
    service_account = "aws-node"
  }

  depends_on = [
    aws_eks_addon.pod_identity_agent
  ]

  tags = {
    Name        = "${local.name_prefix}-vpc-cni"
    Purpose     = "Kubernetes Pod networking"
    ClusterName = var.cluster_name
  }
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "kube-proxy"
  addon_version = var.kube_proxy_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = {
    Name        = "${local.name_prefix}-kube-proxy"
    Purpose     = "Kubernetes service networking"
    ClusterName = var.cluster_name
  }
}

resource "aws_eks_node_group" "system" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  version        = var.cluster_version
  ami_type       = var.node_group_ami_type
  capacity_type  = var.node_group_capacity_type
  instance_types = var.node_group_instance_types
  disk_size      = var.node_group_disk_size

  scaling_config {
    desired_size = var.node_group_desired_size
    min_size     = var.node_group_min_size
    max_size     = var.node_group_max_size
  }

  update_config {
    max_unavailable = 1
  }

  node_repair_config {
    enabled = true
  }

  labels = {
    "node-role" = "system"
    "workload"  = "platform"
  }

  tags = {
    Name        = "${local.name_prefix}-${var.node_group_name}-node-group"
    Purpose     = "EKS platform and observability workloads"
    ClusterName = var.cluster_name
    NodeGroup   = var.node_group_name
  }

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy
  ]

  lifecycle {
    precondition {
      condition = (
        var.node_group_min_size <= var.node_group_desired_size &&
        var.node_group_desired_size <= var.node_group_max_size
      )
      error_message = "Node-group size must satisfy min_size <= desired_size <= max_size."
    }
  }
}

resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "coredns"
  addon_version = var.coredns_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = {
    Name        = "${local.name_prefix}-coredns"
    Purpose     = "Kubernetes cluster DNS"
    ClusterName = var.cluster_name
  }

  depends_on = [
    aws_eks_node_group.system
  ]
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = var.ebs_csi_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  pod_identity_association {
    role_arn        = var.ebs_csi_role_arn
    service_account = "ebs-csi-controller-sa"
  }

  tags = {
    Name        = "${local.name_prefix}-ebs-csi"
    Purpose     = "Kubernetes persistent EBS storage"
    ClusterName = var.cluster_name
  }

  depends_on = [
    aws_eks_node_group.system,
    aws_eks_addon.pod_identity_agent
  ]
}

resource "aws_eks_addon" "metrics_server" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "metrics-server"
  addon_version = var.metrics_server_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  configuration_values = jsonencode({
    replicas = 2

    resources = {
      requests = {
        cpu    = "100m"
        memory = "200Mi"
      }
      limits = {
        cpu    = "500m"
        memory = "512Mi"
      }
    }

    podDisruptionBudget = {
      enabled        = true
      maxUnavailable = 1
    }
  })

  tags = {
    Name        = "${local.name_prefix}-metrics-server"
    Purpose     = "Kubernetes resource metrics API"
    ClusterName = var.cluster_name
  }

  depends_on = [
    aws_eks_node_group.system,
    aws_eks_addon.coredns
  ]
}
