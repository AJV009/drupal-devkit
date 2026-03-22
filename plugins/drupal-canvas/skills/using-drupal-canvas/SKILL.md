---
name: using-drupal-canvas
description: Use when starting any conversation involving Canvas Code Components, Experience Builder, or Drupal CMS component development
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you are working on a Canvas Code Components project and think there is even a 1% chance a skill might apply, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

Canvas components have strict contracts (component.yml, CVA variants, slot decomposition, theme tokens). The skills encode these rules. Skipping them means broken uploads, styling failures, or silent data loss.
</EXTREMELY-IMPORTANT>

## Instruction Priority

drupal-canvas skills provide Canvas-specific guidance, but **user instructions always take precedence**:

1. **User's explicit instructions** (CLAUDE.md, AGENTS.md, direct requests) — highest priority
2. **drupal-canvas skills** — Canvas component patterns and conventions
3. **Default system prompt** — lowest priority

## How to Access Skills

**In Claude Code:** Use the `Skill` tool with the `drupal-canvas:` prefix. Example: invoke `drupal-canvas:canvas-component-authoring` when building components. Never use the Read tool on skill files.

**In Cursor:** Skills are available in the `.cursor-plugin/` configuration.

**In Gemini CLI:** See `GEMINI.md` at the plugin root.

# Skill Catalog

Invoke relevant skills BEFORE any response or action.

## Component Development

- **`canvas-component-authoring`** — Use when building, editing, or fixing any component in src/components/. Covers React 19, Tailwind CSS 4, CVA, cn utility, component.yml, enum naming, image/video props, FormattedText, color variants, theme tokens, slot decomposition, and data fetching with SWR. **This is the primary skill — invoke it for any component work.**
- **`canvas-scaffolding`** — Use when a needed component does not yet exist in src/components/ and must be created. Covers copy-from-example workflow, naming conventions, component contract, and dependency resolution.
- **`canvas-storybook`** — Use when creating, updating, or fixing any Storybook story file. Covers Storybook 10, atomic design hierarchy (atoms/molecules/organisms), CSF3 format, page stories, structural testing, and real assets pattern.

## Project & Content

- **`canvas-project-setup`** — Use when setting up a new Drupal CMS project with Canvas for component development. Covers DDEV, JSON:API write mode, OAuth client, permissions, page regions, menus, CSS layer fix, and Storybook validation. Every step is idempotent — safe to re-run.
- **`canvas-content-management`** — Use when composing pages, adding components to pages, uploading images, or interacting with the Drupal CMS content API via JSON:API. Covers page structure, media handling, input format reference, menu management, and 7 common pitfalls.
- **`canvas-docs-explorer`** — Use when you need to understand how Canvas or Drupal CMS works. Fetches official documentation from curated URL catalog with 13 Canvas docs + Drupal CMS docs + Drupal Core reference.

## Available Agents

- **`canvas-component-builder`** (opus) — Dispatch when building complete Canvas components with Storybook verification. Follows a 6-step process: read requirements → build component → create story → sanity check → composition → validate. Has access to canvas-component-authoring, canvas-scaffolding, canvas-storybook, and canvas-docs-explorer skills.
- **`canvas-storybook-qa`** (sonnet) — Dispatch when you need visual QA comparing Storybook renders against design specs or source site screenshots. Reports discrepancies with severity classification and evidence artifacts.

## Red Flags

These thoughts mean STOP — you're rationalizing skipping a skill:

| Thought | Reality |
|---------|---------|
| "I know React, I can build this" | Canvas components have strict contracts (component.yml, CVA-only colors, no className prop). Check `canvas-component-authoring`. |
| "Let me just create the file" | `canvas-scaffolding` has the copy-from-example workflow and dependency resolution. |
| "The story is simple" | `canvas-storybook` covers atomic design placement, structural testing, and the real assets pattern. |
| "I'll figure out the API" | `canvas-content-management` documents 7 common pitfalls that cause silent failures. |
| "Let me set up the project" | `canvas-project-setup` has the CSS layer fix and OAuth gotchas that break builds. |
| "I can read the docs myself" | `canvas-docs-explorer` has a curated URL catalog and known issues section. |

## Skill Priority

1. **`canvas-component-authoring`** first — for ANY component work, always start here
2. **`canvas-scaffolding`** — only if the component doesn't exist yet
3. **`canvas-storybook`** — after the component is built, create/update the story
4. **`canvas-content-management`** — when composing pages or managing content
5. **`canvas-project-setup`** — only for initial project setup
6. **`canvas-docs-explorer`** — to fill knowledge gaps about Canvas or Drupal CMS
