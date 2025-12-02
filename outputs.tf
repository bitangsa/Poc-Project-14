output "artifacts_bucket" {
  value = module.artifacts.bucket_name
}

output "codebuild_project_name" {
  value = module.codebuild.project_name
}

output "ec2_instance_id" {
  value = module.ec2_web.instance_id
}

output "ec2_public_ip" {
  value = module.ec2_web.public_ip
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "pipeline_name" {
  value = module.codepipeline.pipeline_name
}

output "pipeline_arn" {
  value = module.codepipeline.pipeline_arn
}

output "webhook_url" {
  value = module.codepipeline.webhook_url
}