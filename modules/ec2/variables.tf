variable "project_name" {
  type        = string
  description = "Project name (used in tags and CodeDeploy tag)"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/stage/prod)"
  default     = "Prod"
}

variable "aws_region" {
  type        = string
  description = "AWS region (used in user_data for CodeDeploy agent URL)"
}

variable "name" {
  type        = string
  description = "Base name for the EC2 instance (used in Name tag)"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the instance will be launched"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs attached to the instance"
}

variable "key_name" {
  type        = string
  description = "Existing key pair name (leave empty for no SSH key)"
  default     = ""
}

variable "associate_public_ip" {
  type        = bool
  description = "Whether to associate a public IP"
  default     = true
}

variable "iam_instance_profile_name" {
  type        = string
  description = "IAM instance profile name for SSM/CodeDeploy (optional)"
  default     = ""
}

variable "index_message" {
  type        = string
  description = "Message to put in nginx index.html"
  default     = "Hello from Terraform EC2 with CodeDeploy & Nginx"
}

variable "codedeploy_app_tag_key" {
  type        = string
  description = "EC2 tag key used by CodeDeploy Deployment Group"
  default     = "CodeDeployApp"
}

variable "codedeploy_app_tag_value" {
  type        = string
  description = "EC2 tag value used by CodeDeploy Deployment Group"
}

variable "extra_tags" {
  type        = map(string)
  description = "Any extra tags to add"
  default     = {}
}

variable "region" {
  type = string
}
