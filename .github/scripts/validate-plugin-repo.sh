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
