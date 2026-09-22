#!/usr/bin/env bash
# cli-drills.sh — read-only AWS CLI drills. Safe by default.
# Real calls only with --live; otherwise prints the exact command (dry-run).
# Usage: ./aws/cli-drills.sh [--live]
set -euo pipefail
LIVE=0; [[ "${1:-}" == "--live" ]] && LIVE=1
run() { if (( LIVE )); then eval "$1"; else echo "dry-run: $1"; fi; }

echo "== identity =="
run "aws sts get-caller-identity"
echo "== ec2: list lab instances =="
run "aws ec2 describe-instances --filters Name=tag:Project,Values=cloud-lab --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]' --output table"
echo "== s3: list lab buckets =="
run "aws s3 ls | grep cloudlab || true"
echo "== iam: who am i + password policy =="
run "aws iam get-user --query 'User.[UserName,CreateDate]' --output table"
run "aws iam get-account-password-policy"
echo "== vpc: list lab vpcs =="
run "aws ec2 describe-vpcs --filters Name=tag:Project,Values=cloud-lab --query 'Vpcs[].[VpcId,CidrBlock]' --output table"
