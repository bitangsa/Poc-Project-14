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

module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  cidr_block   = "10.0.0.0/16"
}

module "sg" {
  source       = "./modules/sg"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  admin_cidr   = var.admin_cidr
}

module "iam_ec2" {
  source       = "./modules/iam-ec2"
  project_name = var.project_name
}

module "ec2_web" {
  source = "./modules/ec2"
  aws_region = var.aws_region
    
  project_name = var.project_name          # e.g. "project-14"
  environment  = var.environment           # e.g. "prod"
  region       = var.aws_region          # e.g. "eu-west-1"

  name         = "${var.project_name}-web-1"
  instance_type = "t3.micro"

  subnet_id              = module.vpc.public_subnet_id
  vpc_security_group_ids = [module.sg.sg_id]

  key_name = "bitangsa-key"                # existing key pair name
  associate_public_ip = true

  iam_instance_profile_name = module.iam_ec2.instance_profile_name

  index_message = "Hello This is Bitangsa Saha. Deployed with CodeDeploy."

  # This must match what your CodeDeploy deployment group uses
  codedeploy_app_tag_key   = "CodeDeployApp"
  codedeploy_app_tag_value = var.project_name

  extra_tags = {
    Owner = "Bitangsa"
  }
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

module "codedeploy" {
  source = "./modules/codedeploy"

  project_name  = var.project_name
  ec2_tag_value = var.project_name # must match the tag you set on EC2
}

module "codepipeline" {
  source = "./modules/codepipeline"

  project_name          = var.project_name
  region       = var.aws_region
  artifacts_bucket_name = module.artifacts.bucket_name
  artifacts_bucket_arn  = module.artifacts.bucket_arn

  policy_statements = var.codepipeline_policy_statements


  github_owner       = var.github_owner
  github_repo        = var.github_repo
  github_branch      = var.github_branch
  github_oauth_token = var.github_oauth_token


  codebuild_project_name = module.codebuild.project_name
  codebuild_project_arn  = module.codebuild.project_arn

  codedeploy_app_name              = module.codedeploy.app_name
  codedeploy_deployment_group_name = module.codedeploy.deployment_group_name

  github_webhook_secret = var.github_webhook_secret
}


module "notifications" {
  source = "./modules/notifications"

  project_name       = var.project_name
  notification_email = var.notification_email
  pipeline_name      = module.codepipeline.pipeline_name
}