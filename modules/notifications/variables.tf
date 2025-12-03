variable "project_name" {
  type = string
}

variable "notification_email" {
  type  = list(string)
  description = "Email address to notify on pipeline success/failure"
}

variable "pipeline_name" {
  type = string
  description = "Name of the CodePipeline to watch"
}
