module "networking" {
  source = "../../modules/networking"

  aws_region              = var.aws_region
  project_name            = var.project_name
  environment             = var.environment
  cluster_name            = var.cluster_name
  vpc_cidr                = var.vpc_cidr
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  flow_log_retention_days = var.flow_log_retention_days
}

module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  environment  = var.environment
  cluster_name = var.cluster_name
}

data "aws_caller_identity" "current" {}

module "eks" {
  source = "../../modules/eks"

  project_name                     = var.project_name
  environment                      = var.environment
  cluster_name                     = var.cluster_name
  cluster_version                  = var.cluster_version
  cluster_role_arn                 = module.iam.eks_cluster_role_arn
  private_subnet_ids               = module.networking.private_subnet_ids
  cluster_public_access_cidrs      = var.cluster_public_access_cidrs
  admin_principal_arn              = data.aws_caller_identity.current.arn
  control_plane_log_retention_days = var.control_plane_log_retention_days
  pod_identity_agent_version       = var.pod_identity_agent_version
  vpc_cni_version                  = var.vpc_cni_version
  kube_proxy_version               = var.kube_proxy_version
  vpc_cni_role_arn                 = module.iam.vpc_cni_role_arn
  node_role_arn                    = module.iam.eks_node_role_arn
  node_group_name                  = var.node_group_name
  node_group_instance_types        = var.node_group_instance_types
  node_group_capacity_type         = var.node_group_capacity_type
  node_group_ami_type              = var.node_group_ami_type
  node_group_disk_size             = var.node_group_disk_size
  node_group_desired_size          = var.node_group_desired_size
  node_group_min_size              = var.node_group_min_size
  node_group_max_size              = var.node_group_max_size

  depends_on = [
    module.iam
  ]
}
