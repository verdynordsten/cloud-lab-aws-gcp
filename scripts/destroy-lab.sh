#!/usr/bin/env bash
# destroy-lab.sh — teardown with double confirm. Run after every lab session.
# Usage: ./scripts/destroy-lab.sh aws|gcp
set -euo pipefail
CLOUD="${1:-}"
[[ "$CLOUD" == "aws" || "$CLOUD" == "gcp" ]] || { echo "usage: $0 aws|gcp" >&2; exit 2; }
echo "WARNING: this destroys all $CLOUD lab resources."
read -r -p "type the cloud name to confirm ($CLOUD): " a
[[ "$a" == "$CLOUD" ]] || { echo "aborted"; exit 0; }
read -r -p "really destroy? [y/N] " b
[[ "$b" == "y" || "$b" == "Y" ]] || { echo "aborted"; exit 0; }
cd "$CLOUD" && terraform destroy
