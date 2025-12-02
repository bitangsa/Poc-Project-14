variable "project_name" {
  type = string
}

variable "ec2_tag_key" {
  type        = string
  description = "EC2 tag key to select instances for CodeDeploy"
  default     = "CodeDeployApp"
}

variable "ec2_tag_value" {
  type        = string
  description = "EC2 tag value to select instances for CodeDeploy"
}
