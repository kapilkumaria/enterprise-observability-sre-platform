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
