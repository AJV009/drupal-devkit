---
name: setup-migration
description: Use when starting a new Acquia Source site migration project — bootstraps the project directory with required directory structures, reference files, templates, and validates prerequisites
---

# Migration Project Setup (Acquia Source)

Sets up an Acquia Source + Canvas project for site migration. Run this ONCE before starting any migration work.

## Prerequisites

Before running setup, ensure:
- Node.js and npm are available
- The project has Canvas scaffolding (`npx @drupal-canvas/create`)
- Storybook is configured and can run (`npm run dev`)
- Acquia Source site is accessible with OAuth credentials

## Setup Steps

Run the setup script:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh"
```

This will:

### 1. Create migration directory structure
```
docs/migration/
├── content/           # Verbatim extracted text per page
├── screenshots/
│   └── pages/         # Per-section screenshots (desktop + mobile)
├── issues/            # QA issue artifacts
├── state.jsonl        # Event journal (created by hooks)
├── progress.md        # Phase progress tracker
├── plan.md            # Migration plan (created by site-analyzer)
└── decisions.md       # Agent decision log
```

### 2. Set up canvas-starter reference
Creates `.claude/reference/canvas-starter` symlink pointing to the plugin's bundled canvas-starter skills.

### 3. Copy project templates
If not already present:
- `CLAUDE.md` — Project steering file with MCP server policies and Acquia Source docs
- `.mcp.json` — MCP server configuration for Storybook and Playwright
- `.env.example` — Required environment variables

### 4. Install content management dependencies
Ensures the project has the npm packages needed for content API operations:
```bash
npm install dotenv drupal-jsonapi-params js-yaml
```

### 5. Validate environment
Checks for: node, npm, canvas CLI, storybook

## After Setup

1. Copy `.env.example` to `.env` and configure:
   - `CANVAS_SITE_URL` — Your Acquia Source site URL
   - `CANVAS_CLIENT_ID` — OAuth client ID
   - `CANVAS_CLIENT_SECRET` — OAuth client secret

2. Verify MCP servers in `.mcp.json` have correct URLs

3. Start the migration with: `/migrate-drupal-canvas-source:migrate-site <source-url>`
