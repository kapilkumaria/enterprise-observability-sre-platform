terraform {
  required_version = ">= 1.15.0, < 1.16.0"

  backend "s3" {
    bucket       = "eosre-tfstate-931058976119-us-east-1"
    key          = "bootstrap/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "enterprise-observability-sre-platform"
      Owner       = "Kapil-Kumaria"
    }
  }
}
