# Changelog

All notable changes to Drupal DevKit will be documented in this file.

## [Unreleased]

### Added
- Drupal.org project page and issue queue
- GitLab CI pipeline for MR validation and community plugin sync
- Project description and submission guidelines for Drupal.org

### Changed
- Primary hosting moved to Drupal GitLab (git.drupalcode.org)

## [1.1.0] - 2026-03-25

### Added
- PR validation workflow for community plugin submissions
- Contributing guide and PR template for community contributions

## [1.0.1] - 2026-03-25

### Fixed
- Accept `license` field in plugin.json as LICENSE file fallback
- Use jq `--arg` for injection-safe name collision checks

### Added
- Community plugins section in README
- Testing guide for community plugin registry

## [1.0.0] - 2026-03-24

### Added
- Initial release of drupal-devkit marketplace with 4 bundled plugins
- **drupal-core**: 36 skills covering Drupal coding standards, entity API, Views, SDC, Twig, testing, security, Drush, DDEV, and more
- **drupal-canvas**: 7 skills + 2 agents for Canvas (Drupal CMS) component development
- **migrate-drupal-canvas**: 16 agents for 8-phase site migration to Drupal CMS
- **migrate-drupal-canvas-source**: 15 agents for 8-phase migration from Acquia-hosted sites
- Community plugin registry with automated validation and weekly health checks
- Registry entry validation, plugin repo validation, and marketplace sync scripts
- Support for Claude Code, Cursor, Gemini CLI, and Kiro CLI
- All skills follow the agentskills.io specification
