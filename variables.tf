variable "aws_region" {
  type = string
}

variable "project_name" {
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
  type      = string
  sensitive = true
}

variable "github_webhook_secret" {
  type = string
}

# variable "artifacts_bucket_arn" {
#   type = string
# }

variable "codebuild_policy_statements" {
  type = list(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
}


variable "codepipeline_policy_statements" {
  type = list(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
}

variable "notification_email" {
  type        = string
  description = "Email address for pipeline notifications"
}

variable "region" {
  type = string
  default = "eu-west-1"
}

variable "environment" {
  type = string
}

variable "admin_cidr" {
  type    = string
  default = "0.0.0.0/0"
}