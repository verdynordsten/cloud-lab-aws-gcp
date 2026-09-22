#!/usr/bin/env bash
# cost-guard.sh — blocks terraform apply unless cost is acknowledged
# and the instance size is on the lab allowlist.
# Usage: BUDGET_ACK=1 ./scripts/cost-guard.sh aws   (exit 0 = allowed)
set -euo pipefail
CLOUD="${1:-aws}"
ALLOW_AWS="t2.micro t3.micro t3.small"
ALLOW_GCP="e2-micro e2-small"

[[ "${BUDGET_ACK:-0}" == "1" ]] || {
  echo "blocked: set BUDGET_ACK=1 to confirm you accept cloud charges" >&2; exit 1; }

if [[ "$CLOUD" == "aws" ]]; then
  TYPE="$(grep -E '^\s*default\s*=' aws/variables.tf >/dev/null; python3 -c "
import re
src = open('aws/variables.tf').read()
m = re.search(r'variable \"instance_type\".*?default\s*=\s*\"([^\"]+)\"', src, re.S)
print(m.group(1) if m else '')")"
  [[ " $ALLOW_AWS " == *" $TYPE "* ]] || { echo "blocked: instance_type '$TYPE' not on lab allowlist ($ALLOW_AWS)" >&2; exit 1; }
  echo "allowed: aws $TYPE + BUDGET_ACK=1"
else
  TYPE="$(python3 -c "
import re
src = open('gcp/variables.tf').read()
m = re.search(r'variable \"machine_type\".*?default\s*=\s*\"([^\"]+)\"', src, re.S)
print(m.group(1) if m else '')")"
  [[ " $ALLOW_GCP " == *" $TYPE "* ]] || { echo "blocked: machine_type '$TYPE' not on lab allowlist ($ALLOW_GCP)" >&2; exit 1; }
  echo "allowed: gcp $TYPE + BUDGET_ACK=1"
fi
