terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "artifacts" {
  source       = "./modules/artifacts"
  project_name = var.project_name
}


module "codebuild" {
  source               = "./modules/codebuild"
  project_name         = var.project_name
  artifacts_bucket_arn = module.artifacts.bucket_arn

  policy_statements = var.codebuild_policy_statements
}

module "codepipeline" {
  source = "./modules/codepipeline"

  project_name          = var.project_name
  artifacts_bucket_name = module.artifacts.bucket_name
  artifacts_bucket_arn  = module.artifacts.bucket_arn

  policy_statements = var.codepipeline_policy_statements


  github_owner       = var.github_owner
  github_repo        = var.github_repo
  github_branch      = var.github_branch
  github_oauth_token = var.github_oauth_token

  codebuild_project_name = module.codebuild.project_name
  codebuild_project_arn  = module.codebuild.project_arn

  github_webhook_secret = var.github_webhook_secret
}
