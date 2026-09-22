#!/usr/bin/env bash
# Self-test: terraform shape checks + dry-run drills. No cloud account needed.
set -euo pipefail
cd "$(dirname "$0")/.."
pass=0; fail=0
ok() { pass=$((pass+1)); echo "  ok: $1"; }
bad() { fail=$((fail+1)); echo "  FAIL: $1"; }

echo "[1] bash syntax"
for f in aws/cli-drills.sh scripts/*.sh tests/test.sh aws/userdata.sh; do
  bash -n "$f" && ok "syntax $f" || bad "syntax $f"
done

echo "[2] terraform shape (no terraform binary needed)"
python3 - <<'EOF'
import re
for cloud in ("aws", "gcp"):
    src = open(f"{cloud}/main.tf").read()
    var = open(f"{cloud}/variables.tf").read()
    assert "terraform" in src and "resource" in src, cloud
    assert "variable" in var, cloud + " vars"
    print(cloud, "shape ok")
EOF
[[ $? -eq 0 ]] && ok "tf shape" || bad "tf shape"
python3 - <<'EOF'
import re
# every resource in main.tf must be closable — brace balance check
for cloud in ("aws", "gcp"):
    src = open(f"{cloud}/main.tf").read()
    assert src.count("{") == src.count("}"), cloud + " braces"
print("braces balanced")
EOF
[[ $? -eq 0 ]] && ok "braces" || bad "braces"

echo "[3] aws resources present"
for r in aws_vpc aws_subnet aws_security_group aws_instance aws_s3_bucket; do
  grep -q "resource \"$r\"" aws/main.tf && ok "aws $r" || bad "aws $r"
done
grep -q "0.0.0.0/0" aws/main.tf && grep -q "ssh_cidr" aws/main.tf \
  && ok "ssh restricted via var" || bad "ssh restriction"
grep -q "versioning" aws/main.tf && ok "s3 versioning" || bad "s3 versioning"

echo "[4] gcp resources present"
for r in google_compute_network google_compute_instance google_storage_bucket google_compute_firewall; do
  grep -q "resource \"$r\"" gcp/main.tf && ok "gcp $r" || bad "gcp $r"
done

echo "[5] cli-drills dry-run (default prints, never calls aws)"
if ./aws/cli-drills.sh | grep -q "dry-run: aws sts"; then ok "dry-run default"; else bad "dry-run default"; fi
if ./aws/cli-drills.sh | grep -q "describe-instances"; then ok "ec2 drill"; else bad "ec2 drill"; fi

echo "[6] cost guard blocks by default, allows with ack"
if ./scripts/cost-guard.sh aws 2>/dev/null; then bad "guard blocks w/o ack"; else ok "guard blocks w/o ack"; fi
if BUDGET_ACK=1 ./scripts/cost-guard.sh aws | grep -q allowed; then ok "guard allows aws"; else bad "guard allows aws"; fi
if BUDGET_ACK=1 ./scripts/cost-guard.sh gcp | grep -q allowed; then ok "guard allows gcp"; else bad "guard allows gcp"; fi

echo "[7] no secrets in repo"
if grep -rqiE "ghp_|AKIA|ya29" --include='*.tf' --include='*.sh' --include='*.md' --exclude=test.sh . ; then bad "secret leak"; else ok "no secret leak"; fi
grep -q "0..../32\|CHANGE" aws/variables.tf && ok "ami/ssh placeholders" || bad "placeholders"

echo
echo "pass=$pass fail=$fail"
[[ $fail -eq 0 ]]
