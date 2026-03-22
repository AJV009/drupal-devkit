---
name: using-drupal-core
description: Use when starting any conversation in a Drupal project — establishes available Drupal development skills and when to invoke them
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a Drupal skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.

Drupal APIs have subtle gotchas (cache metadata, render array ordering, hook weights, entity access, config dependencies) that skills address. Skipping a skill means missing these.
</EXTREMELY-IMPORTANT>

## Instruction Priority

drupal-core skills provide Drupal-specific guidance, but **user instructions always take precedence**:

1. **User's explicit instructions** (CLAUDE.md, AGENTS.md, direct requests) — highest priority
2. **drupal-core skills** — Drupal-specific patterns and best practices
3. **Default system prompt** — lowest priority

## How to Access Skills

**In Claude Code:** Use the `Skill` tool with the `drupal-core:` prefix. Example: invoke `drupal-core:drupal-entity-api` when working with entities. Never use the Read tool on skill files.

**In Cursor:** Skills are available in the `.cursor-plugin/` configuration.

**In Gemini CLI:** See `GEMINI.md` at the plugin root.

# Skill Catalog

Invoke relevant skills BEFORE any response or action. Even a 1% chance a skill might apply means you should invoke it.

## Coding & Quality

- **`drupal-coding-standards`** — Use when checking PHPCS/PHPStan, enforcing code style, or starting a new module
- **`drupal-coding-standards-rt`** — Use when reviewing Drupal code for standards compliance across PHP, JavaScript, CSS, Twig, YAML, SQL, and markup — dynamically loads relevant standards per file type
- **`drupal-conventions`** — Use when working on translations, CSS patterns, or error handling
- **`drupal-rules`** — ALWAYS consult when writing any Drupal code — covers security, code quality, and testing verification rules
- **`custom-drupal-module`** — Use when generating a new Drupal module from scratch

## Architecture & Patterns

- **`drupal-entity-api`** — Use when designing content types, selecting field types, or performing entity CRUD
- **`drupal-field-system`** — Use when managing fields, form display widgets, or view display formatters
- **`drupal-hook-patterns`** — Use when implementing hooks, form alters, or event subscribers (covers OOP hooks and legacy bridge)
- **`drupal-service-di`** — Use when creating services, registering dependencies, or understanding DI patterns
- **`drupal-caching`** — Use when implementing caching, optimizing performance, or configuring cache backends
- **`drupal-views`** — Use when creating or modifying Views displays, fields, filters, sorts, or relationships
- **`drupal-sdc`** — Use when creating Single Directory Components with component.yml, Twig, props, and slots

## Testing & Security

- **`drupal-testing`** — Use when verifying implementations via curl, drush eval, or test scripts
- **`drupal-visual-regression`** — Use when setting up Playwright or BackstopJS visual regression tests
- **`accessibility`** — Use when checking WCAG 2.2 compliance, keyboard navigation, or ARIA patterns
- **`drupal-security-patterns`** — Use when reviewing code for OWASP patterns, XSS, SQL injection, or access control
- **`drupal-security-audit`** — Use when performing a comprehensive security assessment of a Drupal site

## Frontend & Theming

- **`twig-templating`** — Use when creating Twig templates, theme suggestions, or front-end markup
- **`drupal-frontend-expert`** — Use when working with SDC theming, CSS/JS libraries, or Drupal.behaviors
- **`drupal-storybook`** — Use when creating Storybook stories for Drupal SDC components

## API & Content

- **`drupal-json-api`** — Use when interacting with Drupal content via JSON:API (GET, POST, PATCH, DELETE, filtering, includes)
- **`drupal-content-moderation`** — Use when setting up editorial workflows, managing publishing states, or content approval
- **`drupal-search-api`** — Use when configuring search backends, indexes, processors, or facets
- **`drupal-eca`** — Use when creating automated reactions to site events with ECA workflows

## Development Tools

- **`drupal-ddev`** — Use when setting up or configuring DDEV local development environments
- **`drush`** — Use when running Drush commands for site management, cron, cache, config, or database operations
- **`drupal-docs-explorer`** — Use when you need authoritative Drupal documentation from drupal.org
- **`drupal-contribute-fix`** — REQUIRED when user mentions a Drupal.org issue, patch, or module bug — full triage workflow

## Reference & Workflow

- **`drupal-at-your-fingertips`** — Use when you need Drupal API patterns across 50+ topics (services, hooks, forms, entities, caching, testing)
- **`drupal-contrib-mgmt`** — Use when updating modules, resolving Composer dependency issues, or checking D11 compatibility
- **`drupal-config-management`** — Use when working with config export/import, config split, or multi-environment deployments
- **`debug`** — Use when diagnosing Drupal code-level issues across 10 debugging categories
- **`refactor`** — Use when reviewing code for anti-patterns, god classes, or refactoring opportunities
- **`migrate`** — Use when importing, rolling back, or debugging Drupal migrations (Migrate API)
- **`performance`** — Use when optimizing caching, queries, assets, BigPipe, or profiling

## Available Agent

- **`drupal-expert`** — General-purpose Drupal development subagent. Dispatch for architecture questions, API lookups, or multi-step Drupal tasks.

## Red Flags

These thoughts mean STOP — you're rationalizing skipping a skill:

| Thought | Reality |
|---------|---------|
| "I know Drupal well enough" | Skills contain version-specific API patterns, edge cases, and gotchas you may not recall |
| "Let me just write the module" | Check `custom-drupal-module` and `drupal-rules` first |
| "This is a simple config change" | `drupal-config-management` covers pitfalls with config split, environments, and overrides |
| "I'll review the code myself" | `drupal-coding-standards` and `drupal-security-patterns` catch what you miss |
| "The hook is straightforward" | `drupal-hook-patterns` covers OOP hooks, legacy bridge, and common ordering issues |
| "I can figure out the entity structure" | `drupal-entity-api` and `drupal-field-system` have field type matrices and access control patterns |
| "Let me just query the database" | `drupal-views` or `drupal-json-api` — never raw SQL unless the skill says to |

## Skill Priority

When multiple skills could apply:

1. **Process skills first** (`debug`, `drupal-rules`, `drupal-coding-standards`) — these determine HOW to approach the task
2. **Domain skills second** (`drupal-entity-api`, `drupal-views`, `drupal-sdc`) — these guide implementation
3. **Reference skills last** (`drupal-at-your-fingertips`, `drupal-docs-explorer`) — fill knowledge gaps

"Build a content type" → `drupal-rules` first, then `drupal-entity-api` + `drupal-field-system`.
"Fix this module bug" → `debug` first, then relevant domain skill.
"Set up local dev" → `drupal-ddev` + `drush`.
