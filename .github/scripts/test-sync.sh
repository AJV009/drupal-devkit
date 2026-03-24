#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PASS=0
FAIL=0

assert_pass() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    PASS=$((PASS + 1))
  else
    echo "FAIL: $desc"
    FAIL=$((FAIL + 1))
  fi
}

assert_fail() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "FAIL (expected failure): $desc"
    FAIL=$((FAIL + 1))
  else
    PASS=$((PASS + 1))
  fi
}

# --- Registry entry validation tests ---

BUNDLED='["drupal-core","drupal-canvas","migrate-drupal-canvas","migrate-drupal-canvas-source"]'
COMMUNITY='[]'

# Valid entry should pass
assert_pass "valid entry passes" bash -c "echo '{\"name\":\"drupal-workflow\",\"repo\":\"gkastanis/drupal-workflow\",\"description\":\"A valid plugin\",\"author\":\"Test\",\"license\":\"MIT\",\"category\":\"development\"}' | $SCRIPT_DIR/validate-registry-entry.sh '$BUNDLED' '$COMMUNITY'"

# Missing name should fail
assert_fail "missing name fails" bash -c "echo '{\"repo\":\"user/repo\",\"description\":\"test\",\"author\":\"Test\",\"license\":\"MIT\",\"category\":\"development\"}' | $SCRIPT_DIR/validate-registry-entry.sh '$BUNDLED' '$COMMUNITY'"

# Invalid repo format should fail
assert_fail "bad repo format fails" bash -c "echo '{\"name\":\"test-plugin\",\"repo\":\"just-a-name\",\"description\":\"test\",\"author\":\"Test\",\"license\":\"MIT\",\"category\":\"development\"}' | $SCRIPT_DIR/validate-registry-entry.sh '$BUNDLED' '$COMMUNITY'"

# Name collision with bundled should fail
assert_fail "bundled name collision fails" bash -c "echo '{\"name\":\"drupal-core\",\"repo\":\"user/repo\",\"description\":\"test\",\"author\":\"Test\",\"license\":\"MIT\",\"category\":\"development\"}' | $SCRIPT_DIR/validate-registry-entry.sh '$BUNDLED' '$COMMUNITY'"

# Name with uppercase should fail
assert_fail "uppercase name fails" bash -c "echo '{\"name\":\"Drupal-Workflow\",\"repo\":\"user/repo\",\"description\":\"test\",\"author\":\"Test\",\"license\":\"MIT\",\"category\":\"development\"}' | $SCRIPT_DIR/validate-registry-entry.sh '$BUNDLED' '$COMMUNITY'"

# Duplicate community name should fail
COMMUNITY_DUP='["drupal-workflow"]'
assert_fail "duplicate community name fails" bash -c "echo '{\"name\":\"drupal-workflow\",\"repo\":\"other/repo\",\"description\":\"test\",\"author\":\"Test\",\"license\":\"MIT\",\"category\":\"development\"}' | $SCRIPT_DIR/validate-registry-entry.sh '$BUNDLED' '$COMMUNITY_DUP'"

# Name exceeding 64 chars should fail
LONG_NAME="abcdefghijklmnopqrstuvwxyz-abcdefghijklmnopqrstuvwxyz-abcdefghijk"
assert_fail "name over 64 chars fails" bash -c "echo '{\"name\":\"$LONG_NAME\",\"repo\":\"user/repo\",\"description\":\"test\",\"author\":\"Test\",\"license\":\"MIT\",\"category\":\"development\"}' | $SCRIPT_DIR/validate-registry-entry.sh '$BUNDLED' '$COMMUNITY'"

# Description exceeding 256 chars should fail
LONG_DESC=$(printf 'x%.0s' $(seq 1 257))
assert_fail "description over 256 chars fails" bash -c "echo '{\"name\":\"test-plugin\",\"repo\":\"user/repo\",\"description\":\"$LONG_DESC\",\"author\":\"Test\",\"license\":\"MIT\",\"category\":\"development\"}' | $SCRIPT_DIR/validate-registry-entry.sh '$BUNDLED' '$COMMUNITY'"

# --- INSERT ADDITIONAL TESTS ABOVE THIS LINE ---

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
