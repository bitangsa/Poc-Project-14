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

# variable "artifacts_bucket_arn" {
#   type = string
# }

variable "codebuild_policy_statements" {
  type = list(object({
    effect = string
    actions = list(string)
    resources = list(string)
  }))
}


variable "codepipeline_policy_statements" {
  type = list(object({
    effect = string
    actions = list(string)
    resources = list(string)
  }))
}