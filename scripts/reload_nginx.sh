#!/bin/bash
set -e

echo "Reloading nginx..."
systemctl restart nginx
