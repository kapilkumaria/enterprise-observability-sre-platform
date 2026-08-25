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
