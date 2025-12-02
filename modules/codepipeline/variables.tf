variable "project_name" {
  type = string
}

variable "artifacts_bucket_name" {
  type = string
}

variable "artifacts_bucket_arn" {
  type = string
}

variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_branch" {
  type = string
}

variable "github_oauth_token" {
  type = string
}

variable "codebuild_project_name" {
  type = string
}

variable "codebuild_project_arn" {
  type = string
}

variable "github_webhook_secret" {
  type      = string
  sensitive = true
  # default   = "dummy"
}

variable "policy_statements" {
  type = list(object({
    effect = string
    actions = list(string)
    resources = list(string)
  }))
}

variable "codedeploy_app_name" {
  type        = string
  description = "CodeDeploy application name"
}

variable "codedeploy_deployment_group_name" {
  type        = string
  description = "CodeDeploy deployment group name"
}

variable "region" {
  type = string
}