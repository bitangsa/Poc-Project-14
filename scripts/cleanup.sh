#!/bin/bash

set -e

echo "Cleaning old configuration files"
rm -rf /usr/share/nginx/html/*
mkdir -p /usr/share/nginx/html