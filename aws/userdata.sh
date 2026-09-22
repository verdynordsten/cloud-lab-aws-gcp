#!/usr/bin/env bash
# userdata: first-boot bootstrap for the lab EC2 (Amazon Linux 2023).
set -euo pipefail
dnf install -y nginx
systemctl enable --now nginx
echo '{"status":"ok","lab":"cloud-lab-aws"}' > /usr/share/nginx/html/healthz
systemctl restart nginx
