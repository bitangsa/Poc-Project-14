# Look up latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

locals {
  codedeploy_tag = {
    (var.codedeploy_app_tag_key) = var.codedeploy_app_tag_value
  }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  associate_public_ip_address = var.associate_public_ip

  key_name = var.key_name != "" ? var.key_name : null

  iam_instance_profile = var.iam_instance_profile_name != "" ? var.iam_instance_profile_name : null

  user_data = base64encode(
    templatefile("${path.module}/userdata.tpl", {
      region        = var.aws_region
      index_message = var.index_message
    })
  )
  tags = merge(
    {
      Name        = var.name
      Project     = var.project_name
      Environment = var.environment
    },
    local.codedeploy_tag,
    var.extra_tags
  )
}


