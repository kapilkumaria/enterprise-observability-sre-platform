output "eks_cluster_role_name" {
  description = "Name of the EKS control-plane IAM role."
  value       = aws_iam_role.eks_cluster.name
}

output "eks_cluster_role_arn" {
  description = "ARN of the EKS control-plane IAM role."
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_name" {
  description = "Name of the EKS managed-node IAM role."
  value       = aws_iam_role.eks_node.name
}

output "eks_node_role_arn" {
  description = "ARN of the EKS managed-node IAM role."
  value       = aws_iam_role.eks_node.arn
}

output "vpc_cni_role_name" {
  description = "Name of the VPC CNI Pod Identity role."
  value       = aws_iam_role.vpc_cni.name
}

output "vpc_cni_role_arn" {
  description = "ARN of the VPC CNI Pod Identity role."
  value       = aws_iam_role.vpc_cni.arn
}

output "ebs_csi_role_name" {
  description = "Name of the EBS CSI Pod Identity role."
  value       = aws_iam_role.ebs_csi.name
}

output "ebs_csi_role_arn" {
  description = "ARN of the EBS CSI Pod Identity role."
  value       = aws_iam_role.ebs_csi.arn
}
