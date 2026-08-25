output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "IPv4 CIDR assigned to the VPC."
  value       = aws_vpc.this.cidr_block
}

output "availability_zones" {
  description = "Availability Zones used by the network."
  value       = local.availability_zones
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = values(aws_subnet.public)[*].id
}

output "public_subnet_cidrs" {
  description = "CIDRs assigned to the public subnets."
  value       = values(aws_subnet.public)[*].cidr_block
}

output "private_subnet_ids" {
  description = "IDs of the private subnets used by EKS worker nodes."
  value       = values(aws_subnet.private)[*].id
}

output "private_subnet_cidrs" {
  description = "CIDRs assigned to the private subnets."
  value       = values(aws_subnet.private)[*].cidr_block
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway."
  value       = aws_nat_gateway.this.id
}

output "nat_gateway_public_ip" {
  description = "Public IPv4 address assigned to the NAT Gateway."
  value       = aws_eip.nat.public_ip
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table."
  value       = aws_route_table.private.id
}

output "s3_vpc_endpoint_id" {
  description = "ID of the S3 Gateway VPC endpoint."
  value       = aws_vpc_endpoint.s3.id
}

output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log."
  value       = aws_flow_log.this.id
}

output "vpc_flow_log_group_name" {
  description = "CloudWatch log-group name used by VPC Flow Logs."
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
}
