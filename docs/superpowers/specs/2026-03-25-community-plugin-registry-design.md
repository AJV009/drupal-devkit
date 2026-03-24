# Community Plugin Registry

**Date:** 2026-03-25
**Status:** Approved

## Problem

The drupal-devkit marketplace currently bundles all plugins as local directories within the repo. This model requires vendoring external plugin code, creates maintenance burden when upstream plugins evolve, and provides no scalable path for community contributions beyond full-code PRs.

## Goals

1. **Discoverability** — Community plugins installable from the drupal-devkit marketplace with the same UX as bundled plugins
2. **Author independence** — External plugin authors keep full control of their repos and iterate freely
3. **Community scale** — Plugin authors contribute a ~6-line JSON entry, not their entire codebase

## Design

### Community Registry

A new file at the repo root: `community-registry.json`

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

**Contributor-submitted fields:** `name`, `repo`, `description`, `author`, `license`, `category`

**GH Action-managed fields:** `enabled`, `last_checked`, `last_failed`

- `enabled`: `null` (new, not yet validated), `true` (passes validation), `false` (fails validation)
- `last_checked`: ISO 8601 timestamp of last validation run
- `last_failed`: `null` (healthy/never failed) or ISO 8601 timestamp of when failures started. Stays set across consecutive failures to track downtime duration. Resets to `null` on recovery.

### GitHub Action

File: `.github/workflows/sync-community-plugins.yml`

**Triggers:**

| Trigger | Behavior |
|---------|----------|
| Push to `main` that modifies `community-registry.json` | Full validation run on ALL entries |
| Weekly schedule | Full validation run on ALL entries |
| Manual dispatch | Full validation run on ALL entries |

The push trigger uses a `paths:` filter on `community-registry.json` only — README edits, bundled plugin changes, etc. do not trigger the action. Weekly schedule covers staleness detection for all other cases.

**Concurrency:** The action uses `concurrency: {group: "community-plugin-sync", cancel-in-progress: false}` to prevent overlapping runs from racing on commits.

**Infinite loop prevention:** The action commits using `github-actions[bot]` and skips execution when `github.actor == 'github-actions[bot]'`. This prevents the action's own commits from re-triggering itself.

**Registry entry validation (before cloning):**

1. All required fields present: `name`, `repo`, `description`, `author`, `license`, `category`
2. `name` is kebab-case, max 64 characters
3. `repo` matches `owner/repo` pattern
4. `name` does not collide with any bundled plugin or other community entry
5. `description` is non-empty, max 256 characters

**Plugin repo validation (after cloning):**

1. Shallow clone (`--depth 1`) with 60-second timeout per repo
2. Check repo exists and is publicly accessible
3. `.claude-plugin/plugin.json` exists and is valid JSON with `name` field
4. `name` in remote plugin.json matches the registry entry `name`
5. Has at least one of: `skills/`, `agents/`, `commands/`, `hooks/`
6. SKILL.md files have valid YAML frontmatter
7. `hooks/hooks.json` is valid JSON (if present)
8. License present in repo

**On validation result:**

- Pass: `enabled: true`, `last_checked: now`, `last_failed: null`
- Fail: `enabled: false`, `last_checked: now`, `last_failed: now` (or keep existing timestamp if already failing)

**Marketplace sync:**

- For each `enabled: true` entry: ensure marketplace.json has a native GitHub source entry
- For each `enabled: false` entry: remove from marketplace.json
- Commit updated `community-registry.json` and `.claude-plugin/marketplace.json`

The action never touches bundled plugins (drupal-core, drupal-canvas, etc.).

**Plugin removal:** Removing an entry from `community-registry.json` via PR causes the action to remove the corresponding marketplace.json entry on the next run.

### Updated marketplace.json

After the GH Action runs, marketplace.json contains both bundled and community plugins:

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "drupal-devkit",
  "description": "Drupal development skills, agents, and MCP configs for AI-assisted Drupal development",
  "owner": {
    "name": "FreelyGive",
    "email": "hello@freelygive.org"
  },
  "plugins": [
    {
      "name": "drupal-core",
      "description": "35 curated Drupal development skills...",
      "source": "./plugins/drupal-core",
      "category": "development"
    },
    {
      "name": "drupal-canvas",
      "description": "Canvas Code Component development...",
      "source": "./plugins/drupal-canvas",
      "category": "development"
    },
    {
      "name": "migrate-drupal-canvas",
      "description": "Site migration orchestrator for Drupal CMS + Canvas...",
      "source": "./plugins/migrate-drupal-canvas",
      "category": "development"
    },
    {
      "name": "migrate-drupal-canvas-source",
      "description": "Site migration orchestrator for Acquia Source + Canvas...",
      "source": "./plugins/migrate-drupal-canvas-source",
      "category": "development"
    },
    {
      "name": "drupal-workflow",
      "description": "3-layer semantic docs, structural index generators, quality gate hooks, and 4 specialized agents",
      "source": {"source": "github", "repo": "gkastanis/drupal-workflow"},
      "category": "development"
    }
  ]
}
```

Bundled plugins use local `./plugins/` paths (manually maintained). Community plugins use native GitHub sources (auto-managed by GH Action). Both coexist in the same `plugins` array.

### Key Design Decision: Native Claude Code Source Resolution

Claude Code's marketplace.json natively supports remote plugin sources:

```json
{"source": {"source": "github", "repo": "owner/repo"}}
```

Claude Code handles cloning, caching to `~/.claude/plugins/cache`, and updates automatically. This eliminates the need for proxy plugins, wrapper directories, resolve scripts, or SessionStart hooks.

## User Experience

**Plugin consumers:**

```bash
# One-time marketplace setup (same as today)
/plugin marketplace add AJV009/drupal-devkit

# Install any plugin (bundled or community — identical UX)
/plugin install drupal-core@drupal-devkit
/plugin install drupal-workflow@drupal-devkit

# Update any plugin
/plugin update drupal-workflow@drupal-devkit
```

**Community plugin authors** submit a PR adding to `community-registry.json`:

```json
{
  "name": "my-drupal-plugin",
  "repo": "myuser/my-drupal-plugin",
  "description": "What it does",
  "author": "My Name",
  "license": "MIT",
  "category": "development"
}
```

**Marketplace maintainer:** Zero ongoing work per plugin. The GH Action validates weekly, disables dead repos, and keeps marketplace.json in sync. Only the initial PR needs review.

## Files Changed

| File | Change |
|------|--------|
| `community-registry.json` (new) | Community plugin registry |
| `.github/workflows/sync-community-plugins.yml` (new) | Validation + marketplace sync action |
| `.claude-plugin/marketplace.json` (modified) | Community entries auto-appended by GH Action |
| `CONTRIBUTING.md` (modified) | Add community plugin submission instructions |
| `README.md` (modified) | Add community plugins section |

## Out of Scope

- npm source support (can be added later per entry)
- Version pinning / ref targeting (external authors manage their own versioning; default branch is used)
- Plugin dependency resolution between community plugins
- Automated PR creation for new community submissions
- PR-time validation check (future enhancement — currently validation runs post-merge)
- Escalation policy for long-failing plugins (tracked via `last_failed` but no automated action yet)
