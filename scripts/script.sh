#!/bin/bash

yum update -y
amazon-linux-extras install nginx1
systemctl enable nginx
systemctl start nginx
echo "This is for Poc project 14"