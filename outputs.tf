output "artifacts_bucket" {
  value = module.artifacts.bucket_name
}

output "codebuild_project_name" {
  value = module.codebuild.project_name
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