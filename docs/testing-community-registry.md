# Testing the Community Plugin Registry

## Run the test suite

```bash
bash .github/scripts/test-sync.sh
```

Runs 17 tests covering registry entry validation, plugin repo validation, and marketplace sync. Expected output:

```
Results: 17 passed, 0 failed
```

## Test individual scripts

### Validate a registry entry

```bash
echo '{"name":"my-plugin","repo":"user/repo","description":"test","author":"Test","license":"MIT","category":"development"}' \
  | .github/scripts/validate-registry-entry.sh \
    '["drupal-core","drupal-canvas","migrate-drupal-canvas","migrate-drupal-canvas-source"]' \
    '[]'
```

Expected: `OK: my-plugin`

Arguments:
- 1st: JSON array of bundled plugin names (for collision check)
- 2nd: JSON array of other community plugin names (for collision check)

### Validate a plugin repo locally

```bash
.github/scripts/validate-plugin-repo.sh /path/to/plugin-dir "expected-name"
```

Checks: plugin.json exists and valid, name matches, has skills/agents/commands/hooks, SKILL.md frontmatter, hooks.json valid, LICENSE present.

### Dry-run marketplace sync

```bash
# Backup, sync, inspect, restore
cp .claude-plugin/marketplace.json /tmp/marketplace-backup.json
.github/scripts/sync-marketplace.sh community-registry.json .claude-plugin/marketplace.json
jq . .claude-plugin/marketplace.json
cp /tmp/marketplace-backup.json .claude-plugin/marketplace.json
```

Note: With `enabled: null` (new entry, not yet validated), no community plugins will be added. To test the sync adding a plugin, temporarily set `enabled: true` in community-registry.json.

## Test the GitHub Action

### Trigger manually

Go to **Actions > Sync Community Plugins > Run workflow** on GitHub, or:

```bash
gh workflow run sync-community-plugins.yml
```

### Watch the run

```bash
gh run list --workflow=sync-community-plugins.yml --limit=1
gh run view <run-id> --log
```

### Verify results after the action runs

```bash
# Pull the action's changes
git pull

# Check registry was updated with validation results
jq '.plugins[] | {name, enabled, last_checked, last_failed}' community-registry.json

# Check marketplace.json has community entries
jq '[.plugins[] | select(.source | type == "object")] | length' .claude-plugin/marketplace.json
```

Expected: `enabled: true`, `last_checked` set, `last_failed: null` for drupal-workflow. Marketplace should show 1 community plugin.

## Test installing a community plugin

After the GH Action has run and synced marketplace.json:

```bash
# Update your local marketplace
/plugin marketplace update drupal-devkit

# Install the community plugin
/plugin install drupal-workflow@drupal-devkit
```

## What the action validates per plugin

1. Registry entry schema (required fields, kebab-case name, repo format, no collisions)
2. Repo accessible and cloneable (60s timeout, shallow clone)
3. `.claude-plugin/plugin.json` exists, valid JSON, name matches
4. Has at least one of: `skills/`, `agents/`, `commands/`, `hooks/`
5. All `SKILL.md` files have valid YAML frontmatter
6. `hooks/hooks.json` is valid JSON (if present)
7. LICENSE file present
