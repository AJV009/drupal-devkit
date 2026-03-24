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

# --- Plugin repo validation tests ---

# Create a valid fixture plugin repo
FIXTURE_DIR=$(mktemp -d)
mkdir -p "$FIXTURE_DIR/valid-plugin/.claude-plugin"
echo '{"name": "valid-plugin", "version": "1.0.0"}' > "$FIXTURE_DIR/valid-plugin/.claude-plugin/plugin.json"
mkdir -p "$FIXTURE_DIR/valid-plugin/skills/test-skill"
cat > "$FIXTURE_DIR/valid-plugin/skills/test-skill/SKILL.md" << 'SKILLEOF'
---
name: test-skill
description: A test skill
---
Test skill content.
SKILLEOF
touch "$FIXTURE_DIR/valid-plugin/LICENSE"

# Create a fixture with no skills/agents/commands/hooks
mkdir -p "$FIXTURE_DIR/empty-plugin/.claude-plugin"
echo '{"name": "empty-plugin", "version": "1.0.0"}' > "$FIXTURE_DIR/empty-plugin/.claude-plugin/plugin.json"
touch "$FIXTURE_DIR/empty-plugin/LICENSE"

# Create a fixture with name mismatch
mkdir -p "$FIXTURE_DIR/mismatch-plugin/.claude-plugin"
echo '{"name": "wrong-name", "version": "1.0.0"}' > "$FIXTURE_DIR/mismatch-plugin/.claude-plugin/plugin.json"
mkdir -p "$FIXTURE_DIR/mismatch-plugin/skills/s1"
printf -- "---\nname: s1\ndescription: s\n---\nContent" > "$FIXTURE_DIR/mismatch-plugin/skills/s1/SKILL.md"
touch "$FIXTURE_DIR/mismatch-plugin/LICENSE"

# Create a fixture with invalid hooks.json
mkdir -p "$FIXTURE_DIR/bad-hooks-plugin/.claude-plugin"
echo '{"name": "bad-hooks-plugin", "version": "1.0.0"}' > "$FIXTURE_DIR/bad-hooks-plugin/.claude-plugin/plugin.json"
mkdir -p "$FIXTURE_DIR/bad-hooks-plugin/skills/s1"
printf -- "---\nname: s1\ndescription: s\n---\nContent" > "$FIXTURE_DIR/bad-hooks-plugin/skills/s1/SKILL.md"
mkdir -p "$FIXTURE_DIR/bad-hooks-plugin/hooks"
echo 'not valid json{' > "$FIXTURE_DIR/bad-hooks-plugin/hooks/hooks.json"
touch "$FIXTURE_DIR/bad-hooks-plugin/LICENSE"

# Create a fixture with no LICENSE
mkdir -p "$FIXTURE_DIR/no-license-plugin/.claude-plugin"
echo '{"name": "no-license-plugin", "version": "1.0.0"}' > "$FIXTURE_DIR/no-license-plugin/.claude-plugin/plugin.json"
mkdir -p "$FIXTURE_DIR/no-license-plugin/skills/s1"
printf -- "---\nname: s1\ndescription: s\n---\nContent" > "$FIXTURE_DIR/no-license-plugin/skills/s1/SKILL.md"

assert_pass "valid plugin repo passes" "$SCRIPT_DIR/validate-plugin-repo.sh" "$FIXTURE_DIR/valid-plugin" "valid-plugin"
assert_fail "empty plugin (no skills/agents) fails" "$SCRIPT_DIR/validate-plugin-repo.sh" "$FIXTURE_DIR/empty-plugin" "empty-plugin"
assert_fail "name mismatch fails" "$SCRIPT_DIR/validate-plugin-repo.sh" "$FIXTURE_DIR/mismatch-plugin" "mismatch-plugin"
assert_fail "invalid hooks.json fails" "$SCRIPT_DIR/validate-plugin-repo.sh" "$FIXTURE_DIR/bad-hooks-plugin" "bad-hooks-plugin"
assert_fail "missing LICENSE fails" "$SCRIPT_DIR/validate-plugin-repo.sh" "$FIXTURE_DIR/no-license-plugin" "no-license-plugin"

rm -rf "$FIXTURE_DIR"

# --- Marketplace sync tests ---

SYNC_DIR=$(mktemp -d)

# Create a test marketplace.json with only bundled plugins
cat > "$SYNC_DIR/marketplace.json" << 'MKEOF'
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "drupal-devkit",
  "owner": {"name": "FreelyGive"},
  "plugins": [
    {"name": "drupal-core", "source": "./plugins/drupal-core", "category": "development"}
  ]
}
MKEOF

# Create a registry with one enabled plugin
cat > "$SYNC_DIR/registry.json" << 'REGEOF'
{
  "plugins": [
    {
      "name": "drupal-workflow",
      "repo": "gkastanis/drupal-workflow",
      "description": "Test plugin",
      "author": "Test",
      "license": "MIT",
      "category": "development",
      "enabled": true,
      "last_checked": "2026-03-25T00:00:00Z",
      "last_failed": null
    }
  ]
}
REGEOF

# Sync should add the community plugin
"$SCRIPT_DIR/sync-marketplace.sh" "$SYNC_DIR/registry.json" "$SYNC_DIR/marketplace.json"
COMMUNITY_COUNT=$(jq '[.plugins[] | select(.source | type == "object")] | length' "$SYNC_DIR/marketplace.json")
BUNDLED_COUNT=$(jq '[.plugins[] | select(.source | type == "string")] | length' "$SYNC_DIR/marketplace.json")
assert_pass "sync adds community plugin" [ "$COMMUNITY_COUNT" -eq 1 ]
assert_pass "sync preserves bundled plugin" [ "$BUNDLED_COUNT" -eq 1 ]

# Now disable the plugin and re-sync — should remove it
jq '.plugins[0].enabled = false' "$SYNC_DIR/registry.json" > "$SYNC_DIR/registry2.json"
"$SCRIPT_DIR/sync-marketplace.sh" "$SYNC_DIR/registry2.json" "$SYNC_DIR/marketplace.json"
COMMUNITY_AFTER=$(jq '[.plugins[] | select(.source | type == "object")] | length' "$SYNC_DIR/marketplace.json")
assert_pass "sync removes disabled community plugin" [ "$COMMUNITY_AFTER" -eq 0 ]
assert_pass "sync still preserves bundled plugin" [ "$(jq '[.plugins[] | select(.source | type == "string")] | length' "$SYNC_DIR/marketplace.json")" -eq 1 ]

rm -rf "$SYNC_DIR"

# --- INSERT ADDITIONAL TESTS ABOVE THIS LINE ---

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
