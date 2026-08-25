output "aws_account_id" {
  description = "AWS account containing the Terraform state bucket."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region containing the Terraform state bucket."
  value       = var.aws_region
}

output "state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.arn
}

output "bootstrap_state_key" {
  description = "Future remote-state key for the bootstrap configuration."
  value       = "bootstrap/terraform.tfstate"
}

output "dev_state_key" {
  description = "Remote-state key for the development environment."
  value       = "environments/dev/terraform.tfstate"
}
