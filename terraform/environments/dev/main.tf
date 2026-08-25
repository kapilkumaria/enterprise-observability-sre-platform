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

  depends_on = [
    module.iam
  ]
}
