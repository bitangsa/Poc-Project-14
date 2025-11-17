terraform {
  backend "s3" {
    bucket       = "bsa-tf-state-store"
    key          = "poc-project-14/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }
}
