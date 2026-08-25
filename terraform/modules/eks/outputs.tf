output "cluster_name" {
  description = "Name of the Amazon EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "ARN of the Amazon EKS cluster."
  value       = aws_eks_cluster.this.arn
}

output "cluster_version" {
  description = "Kubernetes version of the Amazon EKS cluster."
  value       = aws_eks_cluster.this.version
}

output "cluster_status" {
  description = "Current status of the Amazon EKS cluster."
  value       = aws_eks_cluster.this.status
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded EKS cluster certificate authority data."
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Security group created by EKS for the cluster."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_oidc_issuer" {
  description = "OIDC issuer URL exposed by the EKS cluster."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for Kubernetes Secrets."
  value       = aws_kms_key.eks_secrets.arn
}

output "control_plane_log_group_name" {
  description = "CloudWatch log group receiving EKS control-plane logs."
  value       = aws_cloudwatch_log_group.eks_control_plane.name
}

output "administrator_access_entry_arn" {
  description = "ARN of the administrator EKS Access Entry."
  value       = aws_eks_access_entry.administrator.access_entry_arn
}

output "pod_identity_agent_version" {
  description = "Installed EKS Pod Identity Agent version."
  value       = aws_eks_addon.pod_identity_agent.addon_version
}

output "vpc_cni_version" {
  description = "Installed Amazon VPC CNI version."
  value       = aws_eks_addon.vpc_cni.addon_version
}

output "kube_proxy_version" {
  description = "Installed kube-proxy version."
  value       = aws_eks_addon.kube_proxy.addon_version
}

output "node_group_name" {
  description = "Name of the EKS managed node group."
  value       = aws_eks_node_group.system.node_group_name
}

output "node_group_arn" {
  description = "ARN of the EKS managed node group."
  value       = aws_eks_node_group.system.arn
}

output "node_group_status" {
  description = "Current status of the EKS managed node group."
  value       = aws_eks_node_group.system.status
}

output "node_group_instance_types" {
  description = "EC2 instance types configured for the managed node group."
  value       = aws_eks_node_group.system.instance_types
}

output "node_group_capacity_type" {
  description = "Capacity type configured for the managed node group."
  value       = aws_eks_node_group.system.capacity_type
}

output "node_group_scaling_config" {
  description = "Scaling configuration of the EKS managed node group."
  value       = aws_eks_node_group.system.scaling_config
}
