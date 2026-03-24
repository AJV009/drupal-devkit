# Community Plugin Registry Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable community plugin authors to list their plugins in the drupal-devkit marketplace by submitting a ~6-line JSON entry, with automated validation and marketplace sync via GitHub Action.

**Architecture:** A `community-registry.json` file at the repo root serves as the contribution surface. A GitHub Action validates external repos (structure, plugin.json, skills/agents presence) and syncs enabled entries into `.claude-plugin/marketplace.json` using Claude Code's native GitHub source resolution. Three standalone bash scripts handle registry validation, plugin repo validation, and marketplace sync respectively.

**Tech Stack:** Bash, jq, GitHub Actions, git

**Spec:** `docs/superpowers/specs/2026-03-25-community-plugin-registry-design.md`

---

### File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `community-registry.json` | Create | Community plugin registry with drupal-workflow as first entry |
| `.github/scripts/validate-registry-entry.sh` | Create | Validates a single registry entry's schema (required fields, format, collisions) |
| `.github/scripts/validate-plugin-repo.sh` | Create | Validates an external plugin repo (clone, structure, plugin.json, skills) |
| `.github/scripts/sync-marketplace.sh` | Create | Reads registry, updates marketplace.json (add enabled, remove disabled) |
| `.github/workflows/sync-community-plugins.yml` | Create | Orchestrates validation + sync, handles triggers/concurrency/commits |
| `.github/scripts/test-sync.sh` | Create | Smoke test that validates all scripts work together against fixtures |
| `CONTRIBUTING.md` | Modify | Add community plugin submission instructions |
| `README.md` | Modify | Add community plugins section |

---

### Task 1: Create community-registry.json

**Files:**
- Create: `community-registry.json`

- [ ] **Step 1: Create the registry file with drupal-workflow as first entry**

```json
{
  "plugins": [
    {
      "name": "drupal-workflow",
      "repo": "gkastanis/drupal-workflow",
      "description": "3-layer semantic docs, structural index generators, quality gate hooks, and 4 specialized agents",
      "author": "George Kastanis",
      "license": "MIT",
      "category": "development",
      "enabled": null,
      "last_checked": null,
      "last_failed": null
    }
  ]
}
```

- [ ] **Step 2: Validate the JSON is well-formed**

Run: `jq . community-registry.json`
Expected: Pretty-printed JSON output with no errors.

- [ ] **Step 3: Commit**

```bash
git add community-registry.json
git commit -m "feat: add community-registry.json with drupal-workflow entry"
```

---

### Task 2: Create registry entry validation script

**Files:**
- Create: `.github/scripts/validate-registry-entry.sh`

This script validates a single registry entry's schema. It reads a JSON entry from stdin and checks all spec requirements.

- [ ] **Step 1: Write the test expectations**

Create `.github/scripts/test-sync.sh` with registry entry validation tests only (we'll add more tests in later tasks):

```bash
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
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `chmod +x .github/scripts/test-sync.sh && bash .github/scripts/test-sync.sh`
Expected: Failures because `validate-registry-entry.sh` doesn't exist yet.

- [ ] **Step 3: Write validate-registry-entry.sh**

```bash
#!/usr/bin/env bash
# Validates a single community registry entry from stdin.
# Usage: echo '{"name":...}' | validate-registry-entry.sh '<bundled_names_json>' '<community_names_json>'
set -euo pipefail

BUNDLED_NAMES="$1"
COMMUNITY_NAMES="$2"

ENTRY=$(cat)

# Check required fields exist and are non-empty strings
for field in name repo description author license category; do
  val=$(echo "$ENTRY" | jq -r ".$field // empty")
  if [ -z "$val" ]; then
    echo "ERROR: Missing or empty required field: $field"
    exit 1
  fi
done

NAME=$(echo "$ENTRY" | jq -r '.name')
REPO=$(echo "$ENTRY" | jq -r '.repo')
DESC=$(echo "$ENTRY" | jq -r '.description')

# name: kebab-case, max 64 chars
if ! echo "$NAME" | grep -qE '^[a-z0-9]([a-z0-9-]*[a-z0-9])?$'; then
  echo "ERROR: name must be kebab-case (lowercase letters, digits, hyphens): $NAME"
  exit 1
fi
if [ ${#NAME} -gt 64 ]; then
  echo "ERROR: name exceeds 64 characters: $NAME"
  exit 1
fi

# repo: must match owner/repo pattern
if ! echo "$REPO" | grep -qE '^[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+$'; then
  echo "ERROR: repo must match owner/repo format: $REPO"
  exit 1
fi

# description: max 256 characters
if [ ${#DESC} -gt 256 ]; then
  echo "ERROR: description exceeds 256 characters"
  exit 1
fi

# name collision: check against bundled plugins
if echo "$BUNDLED_NAMES" | jq -e "index(\"$NAME\")" >/dev/null 2>&1; then
  echo "ERROR: name collides with bundled plugin: $NAME"
  exit 1
fi

# name collision: check against other community plugins
if echo "$COMMUNITY_NAMES" | jq -e "index(\"$NAME\")" >/dev/null 2>&1; then
  echo "ERROR: name collides with another community plugin: $NAME"
  exit 1
fi

echo "OK: $NAME"
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `chmod +x .github/scripts/validate-registry-entry.sh && bash .github/scripts/test-sync.sh`
Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add .github/scripts/validate-registry-entry.sh .github/scripts/test-sync.sh
git commit -m "feat: add registry entry validation script with tests"
```

---

### Task 3: Create plugin repo validation script

**Files:**
- Create: `.github/scripts/validate-plugin-repo.sh`
- Modify: `.github/scripts/test-sync.sh`

This script validates an external plugin repo by shallow-cloning it and checking structure.

- [ ] **Step 1: Add plugin repo validation tests to test-sync.sh**

Insert into `.github/scripts/test-sync.sh` above the `# --- INSERT ADDITIONAL TESTS ABOVE THIS LINE ---` sentinel:

```bash
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
```

- [ ] **Step 2: Run tests to verify the new tests fail**

Run: `bash .github/scripts/test-sync.sh`
Expected: New plugin repo tests fail, registry tests still pass.

- [ ] **Step 3: Write validate-plugin-repo.sh**

```bash
#!/usr/bin/env bash
# Validates an external plugin repo directory.
# Usage: validate-plugin-repo.sh <repo_dir> <expected_name>
# For remote repos, the caller handles cloning. This script validates the local dir.
set -euo pipefail

REPO_DIR="$1"
EXPECTED_NAME="$2"

# Check .claude-plugin/plugin.json exists and is valid JSON
PLUGIN_JSON="$REPO_DIR/.claude-plugin/plugin.json"
if [ ! -f "$PLUGIN_JSON" ]; then
  echo "ERROR: .claude-plugin/plugin.json not found"
  exit 1
fi

if ! jq empty "$PLUGIN_JSON" 2>/dev/null; then
  echo "ERROR: .claude-plugin/plugin.json is not valid JSON"
  exit 1
fi

# Check name field exists
REPO_NAME=$(jq -r '.name // empty' "$PLUGIN_JSON")
if [ -z "$REPO_NAME" ]; then
  echo "ERROR: plugin.json missing 'name' field"
  exit 1
fi

# Check name matches registry entry
if [ "$REPO_NAME" != "$EXPECTED_NAME" ]; then
  echo "ERROR: plugin.json name '$REPO_NAME' does not match registry name '$EXPECTED_NAME'"
  exit 1
fi

# Check for at least one component directory
HAS_COMPONENTS=false
for dir in skills agents commands hooks; do
  if [ -d "$REPO_DIR/$dir" ] && [ "$(ls -A "$REPO_DIR/$dir" 2>/dev/null)" ]; then
    HAS_COMPONENTS=true
    break
  fi
done

if [ "$HAS_COMPONENTS" = false ]; then
  echo "ERROR: No skills/, agents/, commands/, or hooks/ directory found with content"
  exit 1
fi

# Validate SKILL.md frontmatter (if skills/ exists)
if [ -d "$REPO_DIR/skills" ]; then
  while IFS= read -r -d '' skill_file; do
    # Check for YAML frontmatter delimiters
    FIRST_LINE=$(head -1 "$skill_file")
    if [ "$FIRST_LINE" != "---" ]; then
      echo "ERROR: $skill_file missing YAML frontmatter (no opening ---)"
      exit 1
    fi
    # Check closing delimiter exists
    CLOSING=$(tail -n +2 "$skill_file" | grep -n '^---$' | head -1)
    if [ -z "$CLOSING" ]; then
      echo "ERROR: $skill_file missing closing --- in frontmatter"
      exit 1
    fi
  done < <(find "$REPO_DIR/skills" -name "SKILL.md" -print0)
fi

# Validate hooks/hooks.json if present
HOOKS_JSON="$REPO_DIR/hooks/hooks.json"
if [ -f "$HOOKS_JSON" ]; then
  if ! jq empty "$HOOKS_JSON" 2>/dev/null; then
    echo "ERROR: hooks/hooks.json is not valid JSON"
    exit 1
  fi
fi

# Check LICENSE exists
if ! ls "$REPO_DIR"/LICENSE* >/dev/null 2>&1; then
  echo "ERROR: No LICENSE file found"
  exit 1
fi

echo "OK: Plugin repo validation passed for $EXPECTED_NAME"
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `chmod +x .github/scripts/validate-plugin-repo.sh && bash .github/scripts/test-sync.sh`
Expected: All tests pass (registry + plugin repo).

- [ ] **Step 5: Commit**

```bash
git add .github/scripts/validate-plugin-repo.sh .github/scripts/test-sync.sh
git commit -m "feat: add plugin repo validation script with tests"
```

---

### Task 4: Create marketplace sync script

**Files:**
- Create: `.github/scripts/sync-marketplace.sh`
- Modify: `.github/scripts/test-sync.sh`

This script reads community-registry.json and updates marketplace.json — adding enabled community entries, removing disabled ones, preserving bundled entries.

- [ ] **Step 1: Add marketplace sync tests to test-sync.sh**

Insert into `.github/scripts/test-sync.sh` above the `# --- INSERT ADDITIONAL TESTS ABOVE THIS LINE ---` sentinel:

```bash
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
```

- [ ] **Step 2: Run tests to verify the new tests fail**

Run: `bash .github/scripts/test-sync.sh`
Expected: New sync tests fail, earlier tests still pass.

- [ ] **Step 3: Write sync-marketplace.sh**

```bash
#!/usr/bin/env bash
# Syncs community-registry.json into marketplace.json.
# Adds enabled community plugins, removes disabled/missing ones.
# Never touches bundled plugins (source is a string path).
# Usage: sync-marketplace.sh <registry_path> <marketplace_path>
set -euo pipefail

REGISTRY="$1"
MARKETPLACE="$2"

# Extract enabled community plugins from registry
ENABLED_PLUGINS=$(jq '[.plugins[] | select(.enabled == true)]' "$REGISTRY")

# Read current marketplace
CURRENT=$(cat "$MARKETPLACE")

# Separate bundled plugins (source is a string) from community plugins (source is an object)
BUNDLED=$(echo "$CURRENT" | jq '[.plugins[] | select(.source | type == "string")]')

# Build community entries from enabled registry plugins
COMMUNITY=$(echo "$ENABLED_PLUGINS" | jq '[.[] | {
  name: .name,
  description: .description,
  source: {source: "github", repo: .repo},
  category: .category
}]')

# Merge: bundled first, then community
MERGED=$(jq -n --argjson bundled "$BUNDLED" --argjson community "$COMMUNITY" '$bundled + $community')

# Write updated marketplace.json preserving top-level fields
echo "$CURRENT" | jq --argjson plugins "$MERGED" '.plugins = $plugins' > "$MARKETPLACE"

BUNDLED_COUNT=$(echo "$BUNDLED" | jq 'length')
COMMUNITY_COUNT=$(echo "$COMMUNITY" | jq 'length')
echo "Marketplace synced: $BUNDLED_COUNT bundled, $COMMUNITY_COUNT community plugins"
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `chmod +x .github/scripts/sync-marketplace.sh && bash .github/scripts/test-sync.sh`
Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add .github/scripts/sync-marketplace.sh .github/scripts/test-sync.sh
git commit -m "feat: add marketplace sync script with tests"
```

---

### Task 5: Create GitHub Action workflow

**Files:**
- Create: `.github/workflows/sync-community-plugins.yml`

This workflow orchestrates the three scripts: validate entries, validate repos, update flags, sync marketplace, commit.

- [ ] **Step 1: Write the workflow file**

```yaml
name: Sync Community Plugins

on:
  push:
    branches: [main]
    paths: [community-registry.json]
  schedule:
    - cron: '0 6 * * 1'  # Weekly on Monday at 06:00 UTC
  workflow_dispatch:

concurrency:
  group: community-plugin-sync
  cancel-in-progress: false

permissions:
  contents: write

jobs:
  sync:
    if: github.actor != 'github-actions[bot]'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Install jq
        run: sudo apt-get install -y jq

      - name: Make scripts executable
        run: chmod +x .github/scripts/*.sh

      - name: Extract bundled plugin names
        id: bundled
        run: |
          NAMES=$(jq -c '[.plugins[] | select(.source | type == "string") | .name]' .claude-plugin/marketplace.json)
          echo "names=$NAMES" >> "$GITHUB_OUTPUT"

      - name: Validate and update registry entries
        run: |
          REGISTRY="community-registry.json"
          BUNDLED='${{ steps.bundled.outputs.names }}'
          NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
          PLUGIN_COUNT=$(jq '.plugins | length' "$REGISTRY")

          for i in $(seq 0 $((PLUGIN_COUNT - 1))); do
            ENTRY=$(jq ".plugins[$i]" "$REGISTRY")
            NAME=$(echo "$ENTRY" | jq -r '.name')
            REPO=$(echo "$ENTRY" | jq -r '.repo')

            echo "--- Validating: $NAME ($REPO) ---"

            # Build list of other community names (excluding current)
            COMMUNITY_NAMES=$(jq -c "[.plugins[] | select(.name != \"$NAME\") | .name]" "$REGISTRY")

            # Step 1: Validate registry entry schema
            ENTRY_ONLY=$(echo "$ENTRY" | jq '{name, repo, description, author, license, category}')
            if ! echo "$ENTRY_ONLY" | .github/scripts/validate-registry-entry.sh "$BUNDLED" "$COMMUNITY_NAMES"; then
              echo "  Registry entry validation FAILED"
              PREV_FAILED=$(echo "$ENTRY" | jq -r '.last_failed // empty')
              FAILED_TS="${PREV_FAILED:-$NOW}"
              jq ".plugins[$i].enabled = false | .plugins[$i].last_checked = \"$NOW\" | .plugins[$i].last_failed = \"$FAILED_TS\"" "$REGISTRY" > tmp.json && mv tmp.json "$REGISTRY"
              continue
            fi

            # Step 2: Shallow clone and validate plugin repo
            CLONE_DIR=$(mktemp -d)
            if ! timeout 60 git clone --depth 1 "https://github.com/$REPO.git" "$CLONE_DIR/repo" 2>/dev/null; then
              echo "  Clone FAILED (repo inaccessible or timeout)"
              PREV_FAILED=$(echo "$ENTRY" | jq -r '.last_failed // empty')
              FAILED_TS="${PREV_FAILED:-$NOW}"
              jq ".plugins[$i].enabled = false | .plugins[$i].last_checked = \"$NOW\" | .plugins[$i].last_failed = \"$FAILED_TS\"" "$REGISTRY" > tmp.json && mv tmp.json "$REGISTRY"
              rm -rf "$CLONE_DIR"
              continue
            fi

            if ! .github/scripts/validate-plugin-repo.sh "$CLONE_DIR/repo" "$NAME"; then
              echo "  Plugin repo validation FAILED"
              PREV_FAILED=$(echo "$ENTRY" | jq -r '.last_failed // empty')
              FAILED_TS="${PREV_FAILED:-$NOW}"
              jq ".plugins[$i].enabled = false | .plugins[$i].last_checked = \"$NOW\" | .plugins[$i].last_failed = \"$FAILED_TS\"" "$REGISTRY" > tmp.json && mv tmp.json "$REGISTRY"
              rm -rf "$CLONE_DIR"
              continue
            fi

            rm -rf "$CLONE_DIR"

            # Passed all checks
            echo "  PASSED"
            jq ".plugins[$i].enabled = true | .plugins[$i].last_checked = \"$NOW\" | .plugins[$i].last_failed = null" "$REGISTRY" > tmp.json && mv tmp.json "$REGISTRY"
          done

      - name: Sync marketplace.json
        run: .github/scripts/sync-marketplace.sh community-registry.json .claude-plugin/marketplace.json

      - name: Commit changes
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add community-registry.json .claude-plugin/marketplace.json
          if git diff --cached --quiet; then
            echo "No changes to commit"
          else
            git commit -m "chore: sync community plugins [skip ci]"
            git push
          fi
```

- [ ] **Step 2: Validate the YAML syntax**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/sync-community-plugins.yml'))" && echo "Valid YAML"`
Expected: `Valid YAML`

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/sync-community-plugins.yml
git commit -m "feat: add GitHub Action workflow for community plugin sync"
```

---

### Task 6: Run full test suite

**Files:**
- Read: `.github/scripts/test-sync.sh`

- [ ] **Step 1: Run all tests end-to-end**

Run: `bash .github/scripts/test-sync.sh`
Expected: All tests pass — registry validation, plugin repo validation, marketplace sync.

- [ ] **Step 2: Manually verify sync against real registry**

Run:
```bash
cp .claude-plugin/marketplace.json /tmp/marketplace-backup.json
.github/scripts/sync-marketplace.sh community-registry.json .claude-plugin/marketplace.json
jq . .claude-plugin/marketplace.json
cp /tmp/marketplace-backup.json .claude-plugin/marketplace.json
```
Expected: marketplace.json shows bundled plugins unchanged, no community plugins added (drupal-workflow has `enabled: null`, not `true`).

---

### Task 7: Update CONTRIBUTING.md

**Files:**
- Modify: `CONTRIBUTING.md`

- [ ] **Step 1: Add community plugin submission section**

Add after the existing "Adding a Community Skill" section:

```markdown
## Submitting a Community Plugin

If you maintain a Claude Code plugin for Drupal and want it listed in the drupal-devkit marketplace:

1. Ensure your plugin repo has:
   - `.claude-plugin/plugin.json` with a `name` field
   - At least one of: `skills/`, `agents/`, `commands/`, or `hooks/`
   - A `LICENSE` file
   - Valid YAML frontmatter in all `SKILL.md` files
2. Open a PR adding your plugin to `community-registry.json`:
   ```json
   {
     "name": "your-plugin-name",
     "repo": "your-github-user/your-repo",
     "description": "Brief description (max 256 chars)",
     "author": "Your Name",
     "license": "MIT",
     "category": "development"
   }
   ```
3. The `name` must be kebab-case, max 64 characters, and must not collide with existing plugins
4. After merge, a GitHub Action validates your repo and adds it to the marketplace
5. A weekly health check verifies your repo remains accessible and valid

Your plugin stays in your repo — you maintain full control and can iterate freely.
```

- [ ] **Step 2: Commit**

```bash
git add CONTRIBUTING.md
git commit -m "docs: add community plugin submission guide to CONTRIBUTING.md"
```

---

### Task 8: Update README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add community plugins section**

Add after the "Migration Plugins" section and before "Attribution":

```markdown
## Community Plugins

Community-maintained plugins available through the drupal-devkit marketplace:

| Plugin | Author | Description |
|--------|--------|-------------|
| **drupal-workflow** | George Kastanis | 3-layer semantic docs, structural index generators, quality gate hooks, and 4 specialized agents |

Install community plugins the same way as bundled plugins:

```bash
/plugin install drupal-workflow@drupal-devkit
```

### Submit Your Plugin

Want to list your plugin here? See [CONTRIBUTING.md](CONTRIBUTING.md#submitting-a-community-plugin) for instructions. You submit a ~6-line JSON entry — your code stays in your repo.
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add community plugins section to README"
```

---

### Task 9: Final integration verification

- [ ] **Step 1: Run the full test suite one final time**

Run: `bash .github/scripts/test-sync.sh`
Expected: All tests pass.

- [ ] **Step 2: Verify all files are committed and clean**

Run: `git status`
Expected: Clean working tree.

- [ ] **Step 3: Verify marketplace.json is unchanged** (community entries only added by GH Action, not manually)

Run: `git diff HEAD~1..HEAD -- .claude-plugin/marketplace.json`
Expected: No diff — marketplace.json is only modified by the GH Action, not by this implementation.

- [ ] **Step 4: Review the full commit history**

Run: `git log --oneline -10`
Expected: Clean sequence of focused commits for each task.
