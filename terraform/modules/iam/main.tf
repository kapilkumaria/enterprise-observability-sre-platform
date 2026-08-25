locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    sid     = "AllowEksControlPlane"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${local.name_prefix}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = {
    Name        = "${local.name_prefix}-eks-cluster-role"
    Purpose     = "Amazon EKS control plane"
    ClusterName = var.cluster_name
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    sid     = "AllowEc2Workers"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node" {
  name               = "${local.name_prefix}-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json

  tags = {
    Name        = "${local.name_prefix}-eks-node-role"
    Purpose     = "Amazon EKS managed worker nodes"
    ClusterName = var.cluster_name
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_pull_only" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

data "aws_iam_policy_document" "pod_identity_assume_role" {
  statement {
    sid    = "AllowEksPodIdentity"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vpc_cni" {
  name               = "${local.name_prefix}-vpc-cni-pod-identity-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume_role.json

  tags = {
    Name              = "${local.name_prefix}-vpc-cni-pod-identity-role"
    Purpose           = "VPC CNI Pod Identity"
    ClusterName       = var.cluster_name
    KubernetesService = "kube-system/aws-node"
  }
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  role       = aws_iam_role.vpc_cni.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role" "ebs_csi" {
  name               = "${local.name_prefix}-ebs-csi-pod-identity-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume_role.json

  tags = {
    Name              = "${local.name_prefix}-ebs-csi-pod-identity-role"
    Purpose           = "EBS CSI Pod Identity"
    ClusterName       = var.cluster_name
    KubernetesService = "kube-system/ebs-csi-controller-sa"
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicyV2"
}
