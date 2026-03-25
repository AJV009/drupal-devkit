# drupal-devkit

> **This repository has been archived.** Development has moved to Drupal GitLab: [drupal.org/project/drupal_devkit](https://www.drupal.org/project/drupal_devkit). Please open issues and merge requests there.

Drupal development skills, agents, and MCP configs for AI-assisted Drupal development.

A plugin marketplace that bundles **41 curated skills** from the Drupal community into installable plugins. Works with Claude Code, Cursor, Gemini CLI, Kiro CLI, and other AI coding tools that support the [agentskills.io](https://agentskills.io) standard.

## Quick Start

### Claude Code

```bash
# Add the marketplace
/plugin marketplace add AJV009/drupal-devkit

# Install plugins
/plugin install drupal-core@drupal-devkit
/plugin install drupal-canvas@drupal-devkit
```

### Cursor

Copy the plugin directory into your project and reference `.cursor-plugin/plugin.json`.

### Gemini CLI

Copy the plugin directory and reference `GEMINI.md` for context injection.

### Kiro CLI / Other Tools

Copy the `skills/` directory from any plugin into your project's `.kiro/skills/` or `.agents/skills/` directory. The SKILL.md format is compatible with 30+ AI coding tools.

## Available Plugins

| Plugin | Skills | Agents | Description |
|--------|--------|--------|-------------|
| **drupal-core** | 36 | 1 | Essential Drupal development skills — coding standards, testing, security, entity API, Views, JSON:API, SDC, accessibility, visual regression |
| **drupal-canvas** | 7 | 2 | Canvas Code Component development — React 19, Tailwind 4, CVA, Storybook, content management, project setup |
| **migrate-drupal-canvas** | 9 | 16 | Site migration orchestrator for Drupal CMS + Canvas — 8-phase workflow with visual QA |
| **migrate-drupal-canvas-source** | 9 | 15 | Site migration orchestrator for Acquia Source + Canvas — 8-phase workflow with visual QA |

## Auto-Discovery

Both plugins include **SessionStart hooks** that automatically inject skill catalogs into your session. When you install a plugin and start a new session, your AI assistant will know which skills are available and when to invoke them — no manual configuration needed.

## What's in drupal-core?

36 skills covering the full Drupal development lifecycle:

### Coding & Quality
`drupal-coding-standards` `drupal-coding-standards-rt` `drupal-conventions` `drupal-rules` `custom-drupal-module`

### Architecture & Patterns
`drupal-entity-api` `drupal-hook-patterns` `drupal-service-di` `drupal-caching` `drupal-field-system` `drupal-views` `drupal-sdc`

### Testing & Security
`drupal-testing` `drupal-visual-regression` `accessibility` `drupal-security-patterns` `drupal-security-audit`

### Frontend & Theming
`twig-templating` `drupal-frontend-expert` `drupal-storybook`

### API & Content
`drupal-json-api` `drupal-content-moderation` `drupal-search-api` `drupal-eca`

### Development Tools
`drupal-ddev` `drush` `drupal-docs-explorer` `drupal-contribute-fix`

### Reference & Workflow
`drupal-at-your-fingertips` `drupal-contrib-mgmt` `drupal-config-management` `debug` `refactor` `migrate` `performance`

### Agent
- **drupal-expert** — General-purpose Drupal development subagent for architecture questions and multi-step tasks

### MCP Servers
- **drush-mcp** — Run Drush commands via MCP
- **playwright** — Browser automation for visual testing and Drupal admin UI

## What's in drupal-canvas?

7 skills for building Canvas Code Components on Drupal CMS:

### Component Development
`canvas-component-authoring` `canvas-scaffolding` `canvas-storybook`

### Project & Content
`canvas-project-setup` `canvas-content-management` `canvas-docs-explorer`

### Agents
- **canvas-component-builder** (opus) — Builds complete Canvas components with Storybook verification
- **canvas-storybook-qa** (sonnet) — Visual QA comparing Storybook renders against design specs

### MCP Servers
- **playwright** — Browser automation for Storybook visual testing
- **storybook** — Storybook component navigation and inspection

## Migration Plugins

Two migration orchestrators for full site migrations to Canvas:

### migrate-drupal-canvas (Drupal CMS target)

16 specialized agents orchestrating an 8-phase migration workflow:
1. **Discovery** — site-analyzer + css-extractor crawl source site
2. **Audit** — component-auditor maps existing components to requirements
3. **Build** — component-builder creates React components with Storybook verification
4. **QA Loop** — storybook-qa + component-fixer iterate until visual match
5. **Upload** — upload-verifier pushes components to Canvas
6. **Media** — media-handler transfers assets to Drupal CMS
7. **Content** — content-composer deploys page content via JSON:API
8. **Review** — visual-verifier performs final cross-page verification

**Prerequisites:** DDEV, Drupal CMS, Canvas scaffolding, Storybook, Playwright

```bash
/plugin install migrate-drupal-canvas@drupal-devkit
# Then in your project:
/migrate-drupal-canvas:setup-migration
/migrate-drupal-canvas:migrate-site https://source-site.com
```

### migrate-drupal-canvas-source (Acquia Source target)

Same 8-phase workflow adapted for Acquia Source (SaaS) instead of self-hosted Drupal CMS. 15 agents (no project-setup agent — Acquia Source handles infrastructure).

```bash
/plugin install migrate-drupal-canvas-source@drupal-devkit
/migrate-drupal-canvas-source:setup-migration
/migrate-drupal-canvas-source:migrate-site https://source-site.com
```

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

## Attribution

This marketplace aggregates skills from multiple open-source contributors. See [ATTRIBUTION.md](ATTRIBUTION.md) for full credits.

## Contributing

We welcome contributions from the Drupal community:

- **List your plugin** — Add a ~6-line JSON entry to `community-registry.json`. Your code stays in your repo. See [Submitting a Community Plugin](CONTRIBUTING.md#submitting-a-community-plugin).
- **Add a skill** — Contribute a skill directly to a bundled plugin. See [Adding a Skill](CONTRIBUTING.md#adding-a-skill-to-a-bundled-plugin).
- **Report issues** — Open an issue describing the problem and which plugin/skill is affected.

See [CONTRIBUTING.md](CONTRIBUTING.md) for full details.

## License

MIT
