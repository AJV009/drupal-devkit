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
