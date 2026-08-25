terraform {
  backend "s3" {
    bucket       = "eosre-tfstate-931058976119-us-east-1"
    key          = "environments/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
