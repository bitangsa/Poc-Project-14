#!/bin/bash
yum update -y

# Install CodeDeploy agent (Amazon Linux 2)
yum install -y ruby wget
cd /home/ec2-user
wget https://aws-codedeploy-eu-west-1.s3.eu-west-1.amazonaws.com/latest/install
chmod +x ./install
./install auto
systemctl enable codedeploy-agent
systemctl start codedeploy-agent

# Install nginx
amazon-linux-extras install -y nginx1
systemctl enable nginx
systemctl start nginx

# Simple index page (CodeDeploy can overwrite this later)
echo "${index_message}" > /usr/share/nginx/html/index.html
