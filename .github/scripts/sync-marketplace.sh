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
