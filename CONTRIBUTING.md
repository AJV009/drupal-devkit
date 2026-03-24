# Contributing to drupal-devkit

## Adding a New Skill

1. Create a directory under `plugins/<plugin-name>/skills/<skill-name>/`
2. Add a `SKILL.md` file following the [agentskills.io specification](https://agentskills.io/specification):
   - YAML frontmatter with `name` (max 64 chars, lowercase + hyphens) and `description` (max 1024 chars)
   - Markdown body with instructions, examples, and patterns
   - Keep SKILL.md under 500 lines; use `references/` for detailed content
3. Optional: add `references/`, `scripts/`, or `assets/` subdirectories
4. Open a PR with your skill

## Skill Quality Guidelines

- Skills must be **platform-agnostic** — no references to specific AI tools (Claude Code, Cursor, etc.)
- Skills must be **standalone** — they should work without any project-specific context
- Skills must have proper **attribution** if derived from other work
- No secrets, API keys, or project-specific paths

## Adding a Community Skill

If you want to include an existing community skill:

1. Verify the license allows redistribution (MIT, GPL-2.0, Apache-2.0)
2. Copy the skill directory into the appropriate plugin
3. Add attribution to `ATTRIBUTION.md`
4. Open a PR

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

## Reporting Issues

Open an issue on this repository describing the problem, including which skill is affected.
