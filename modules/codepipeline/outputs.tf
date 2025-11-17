output "pipeline_name" {
  value = aws_codepipeline.this.name
}

output "pipeline_arn" {
  value = aws_codepipeline.this.arn
}

output "webhook_url" {
  value = aws_codepipeline_webhook.github.url
}