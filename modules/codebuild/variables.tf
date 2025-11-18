variable "project_name" {
  type = string
}

variable "artifacts_bucket_arn" {
  type = string
}

variable "policy_statements" {
  type = list(object({
    effect = string
    actions = list(string)
    resources = list(string)
  }))
}