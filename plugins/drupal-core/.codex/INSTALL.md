# Installing Drupal Core DevKit for Codex

## Quick Start

```bash
# Clone the marketplace
git clone https://github.com/AJV009/drupal-devkit.git ~/.codex/drupal-devkit

# Symlink the drupal-core skills into your project
ln -s ~/.codex/drupal-devkit/plugins/drupal-core/skills .agents/skills/drupal-core
```

## Manual Installation

Copy the `skills/` directory from this plugin into your project's `.agents/skills/` directory:

```bash
cp -r plugins/drupal-core/skills/ .agents/skills/drupal-core/
```

## What's Included

- 36 Drupal development skills (coding standards, testing, security, entity API, Views, JSON:API, SDC, and more)
- 1 agent (drupal-expert)
- MCP server configs for drush-mcp and Playwright
