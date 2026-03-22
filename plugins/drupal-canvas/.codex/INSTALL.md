# Installing Drupal Canvas DevKit for Codex

## Quick Start

```bash
# Clone the marketplace
git clone https://github.com/AJV009/drupal-devkit.git ~/.codex/drupal-devkit

# Symlink the drupal-canvas skills into your project
ln -s ~/.codex/drupal-devkit/plugins/drupal-canvas/skills .agents/skills/drupal-canvas
```

## Manual Installation

Copy the `skills/` directory from this plugin into your project's `.agents/skills/` directory:

```bash
cp -r plugins/drupal-canvas/skills/ .agents/skills/drupal-canvas/
```

## What's Included

- 7 Canvas Code Component development skills (component authoring, scaffolding, Storybook, content management, project setup, docs explorer)
- 2 agents (canvas-component-builder, canvas-storybook-qa)
- MCP server configs for Playwright and Storybook
