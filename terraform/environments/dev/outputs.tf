output "vpc_id" {
  description = "ID of the development VPC."
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "CIDR assigned to the development VPC."
  value       = module.networking.vpc_cidr
}

output "availability_zones" {
  description = "Availability Zones used by the development network."
  value       = module.networking.availability_zones
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.networking.private_subnet_ids
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway."
  value       = module.networking.nat_gateway_id
}

output "nat_gateway_public_ip" {
  description = "Public address assigned to the NAT Gateway."
  value       = module.networking.nat_gateway_public_ip
}

output "s3_vpc_endpoint_id" {
  description = "ID of the S3 Gateway VPC endpoint."
  value       = module.networking.s3_vpc_endpoint_id
}

output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log."
  value       = module.networking.vpc_flow_log_id
}

output "vpc_flow_log_group_name" {
  description = "CloudWatch log group receiving VPC Flow Logs."
  value       = module.networking.vpc_flow_log_group_name
}

output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster role."
  value       = module.iam.eks_cluster_role_arn
}

output "eks_node_role_arn" {
  description = "ARN of the EKS managed-node role."
  value       = module.iam.eks_node_role_arn
}

output "vpc_cni_role_arn" {
  description = "ARN of the VPC CNI Pod Identity role."
  value       = module.iam.vpc_cni_role_arn
}

output "ebs_csi_role_arn" {
  description = "ARN of the EBS CSI Pod Identity role."
  value       = module.iam.ebs_csi_role_arn
}

output "cluster_name" {
  description = "Name of the Amazon EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "ARN of the Amazon EKS cluster."
  value       = module.eks.cluster_arn
}

output "cluster_version" {
  description = "Kubernetes version of the Amazon EKS cluster."
  value       = module.eks.cluster_version
}

output "cluster_status" {
  description = "Current status of the Amazon EKS cluster."
  value       = module.eks.cluster_status
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group created by EKS."
  value       = module.eks.cluster_security_group_id
}

output "cluster_oidc_issuer" {
  description = "OIDC issuer URL exposed by the cluster."
  value       = module.eks.cluster_oidc_issuer
}

output "eks_secrets_kms_key_arn" {
  description = "ARN of the KMS key used for Kubernetes Secrets."
  value       = module.eks.kms_key_arn
}

output "eks_control_plane_log_group_name" {
  description = "CloudWatch log group receiving EKS control-plane logs."
  value       = module.eks.control_plane_log_group_name
}
