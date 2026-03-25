# Contributing to drupal-devkit

There are three ways to contribute to drupal-devkit:

1. **Submit a community plugin** — list your own plugin in our marketplace (your code stays in your repo)
2. **Add a skill to a bundled plugin** — contribute a skill directly to drupal-core or another bundled plugin
3. **Report an issue** — let us know about bugs or problems

## Submitting a Community Plugin

This is the recommended way to contribute. You keep full ownership of your repo and can iterate freely. Users install your plugin through the drupal-devkit marketplace just like bundled plugins.

### Requirements

Your plugin repo must have:

- `.claude-plugin/plugin.json` with at least a `name` field
- At least one of: `skills/`, `agents/`, `commands/`, or `hooks/` with content
- A `LICENSE` file (or a `license` field in `plugin.json`)
- Valid YAML frontmatter (`---` delimiters) in all `SKILL.md` files
- Valid JSON in `hooks/hooks.json` (if present)

### How to Submit

1. Fork this repository
2. Add your plugin entry to `community-registry.json`:
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
3. Open a PR using the **Community Plugin Submission** template

### Naming Rules

- `name` must be kebab-case (lowercase letters, digits, hyphens)
- Max 64 characters
- Must not collide with existing bundled or community plugin names

### What Happens After Merge

1. A GitHub Action validates your repo structure automatically
2. If validation passes, your plugin is added to `marketplace.json` and becomes installable
3. A weekly health check verifies your repo remains accessible and valid
4. If your repo goes down, the plugin is temporarily disabled and re-enabled when it comes back

### How Users Install Your Plugin

```bash
/plugin marketplace add AJV009/drupal-devkit
/plugin install your-plugin-name@drupal-devkit
```

## Adding a Skill to a Bundled Plugin

If you want to contribute a skill directly to `drupal-core` or another bundled plugin:

1. Create a directory under `plugins/<plugin-name>/skills/<skill-name>/`
2. Add a `SKILL.md` file following the [agentskills.io specification](https://agentskills.io/specification):
   - YAML frontmatter with `name` (max 64 chars, lowercase + hyphens) and `description` (max 1024 chars)
   - Markdown body with instructions, examples, and patterns
   - Keep SKILL.md under 500 lines; use `references/` for detailed content
3. Optional: add `references/`, `scripts/`, or `assets/` subdirectories
4. Open a PR

### Skill Quality Guidelines

- Skills must be **platform-agnostic** — no references to specific AI tools (Claude Code, Cursor, etc.)
- Skills must be **standalone** — they should work without any project-specific context
- Skills must have proper **attribution** if derived from other work
- No secrets, API keys, or project-specific paths

### Adding an Existing Community Skill

If you want to include a skill from an external repository:

1. Verify the license allows redistribution (MIT, GPL-2.0, Apache-2.0)
2. Copy the skill directory into the appropriate plugin
3. Add attribution to `ATTRIBUTION.md`
4. Open a PR

## Reporting Issues

Open an issue on this repository describing the problem, including which plugin or skill is affected.
