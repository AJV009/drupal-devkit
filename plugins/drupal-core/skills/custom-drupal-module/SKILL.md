---
name: custom-drupal-module
description: Generate complete, installable Drupal 11 modules. This plugin transforms Claude into a senior Drupal architect with deep knowledge of Drupal 11 core APIs, modern development patterns, and best practices.
metadata:
  category: "drupal"
  drupal_version: "11.x"
  php_version: "8.4+"
  symfony_version: "6.x"
  phpunit_version: "9+"
  examples_branch: "4.0.x"
  skill_version: "1.0.0"
  last_updated: "2026-02-10"
  api_reference: "https://api.drupal.org/api/drupal/11.x"
  breaking_changes: "https://www.drupal.org/list-changes/drupal?version=11.x"
---

# Custom Drupal Module

## Overview

This skill enables Claude to act as a senior Drupal 11 architect, generating production-ready, installable Drupal modules using modern PHP 8.2+ syntax, proper dependency injection, and current Drupal 11 APIs. All generated code is compatible with Drupal 11.x, free of deprecated APIs, and follows official Drupal coding standards.

## When to Use

Trigger this skill when:
- User asks to "create a Drupal module"
- User asks to "edit, refactor or improve a Drupal module"
- User requests "Drupal 11 custom entity"
- User wants to "implement Drupal plugin"
- User mentions "Drupal service", "Drupal configuration form", "Drupal controller"
- User needs to "generate Drupal code"
- User asks about Drupal 11 best practices or patterns

## Core Principles

This skill operates under strict guidelines:

1. **Drupal 11.x Only** - All code must be compatible with Drupal 11.x
2. **No Deprecated APIs** - Never use deprecated hooks, functions, or services
3. **Modern Patterns** - Prefer services, dependency injection, event subscribers, and plugin APIs
4. **Modern PHP Stack** - PHP 8.4+, Composer-based, Symfony 6.x components
5. **Coding Standards** - PSR-4 autoloading, 2-space Drupal indentation (NOT PSR-12 4-space)
6. **DDEV Tools Only** - NEVER call `vendor/bin/phpcs`, `vendor/bin/phpcbf`, or `vendor/bin/phpstan` directly; ALWAYS use `ddev phpcs`, `ddev phpcbf`, `ddev phpstan` which apply the Drupal standard and project config
7. **Security First** - Every code change must be reviewed for XSS, SQL injection, CSRF, access control, and command injection before it is considered done
8. **Tests Must Pass** - Run all module tests after every change; do not consider work complete until tests pass

## Instructions

### Step 1: Understand the Request

Analyze what the user needs:
- Custom entity type?
- Plugin implementation?
- Service or controller?
- Configuration form?
- Event subscriber?
- Complete module from scratch?

**Load Reference Documentation:**
When working on specific Drupal subsystems, reference the appropriate documentation from `references/`:
- Entity work → `references/entity-api.md`
- Plugin work → `references/plugin-api.md`
- Configuration → `references/configuration-api.md`
- Caching → `references/cache-api.md`
- Routing → `references/routing-system.md`
- Forms → `references/form-api.md`
- Database → `references/database-api.md`
- Theming → `references/render-theming.md`
- Events → `references/event-system.md`
- Services → `references/dependency-injection.md`
- Security → `references/security.md`
- Testing → `references/testing-quality.md`

### Step 2: Plan the Implementation

Before generating code:

1. **Identify required files** - List all files needed for complete, installable module
2. **Choose architectural approach** - Dependency injection, service container, plugins, etc.
3. **Consider security** - Input validation, output escaping, access control, CSRF protection
4. **Plan caching** - Cache contexts, tags, max-age for optimal performance
5. **Plan test coverage** - Identify what test types are needed (unit, kernel, functional)
6. **Verify API compatibility** - Ensure all APIs exist in Drupal 11.x (reference api.drupal.org)

### Step 3: Generate Complete Code

Produce installable, production-ready code with:

**Required Files for Basic Module:**
- `module_name.info.yml` - Module metadata
- `module_name.permissions.yml` - Custom permissions (if needed)
- `module_name.routing.yml` - Routes (if needed)
- `module_name.services.yml` - Service definitions (if needed)
- `module_name.module` - Hooks and legacy code (minimal, only when necessary)
- `src/` - PSR-4 namespaced classes
- `tests/src/` - Test classes (Unit, Kernel, Functional as appropriate)

**Configuration File Requirements:**
- ✅ **NEVER include `uuid` fields** in generated config files - Drupal generates these automatically on import
- ✅ After importing new config with `drush cim`, run `drush cex` to capture generated UUIDs
- ✅ This applies to all config YAML files: install config, optional config, and config entity exports

**Code Quality Requirements:**
- ✅ Follow patterns from reference files (proper formatting, PHPDoc, naming conventions)
- ✅ 2-space indentation, PSR-12 formatting
- ✅ Proper dependency injection (constructor injection preferred)
- ✅ Complete PHPDoc blocks with @param, @return, @throws tags
- ✅ Type hints on all parameters and return values
- ✅ Proper use of interfaces
- ✅ Cache metadata on all render arrays
- ✅ Access checks on all entity queries (`->accessCheck(TRUE)`)
- ✅ Input validation and output escaping
- ✅ Translatable strings using `$this->t()` or `new TranslatableMarkup()`
- ✅ Proper error handling

**Modern PHP Patterns Required:**
- Arrow functions: `array_map(fn($id) => ['target_id' => $id], $ids)`
- Null coalescing: `$value = $input ?? 'default'`
- Modern string functions: `str_contains()`, `str_starts_with()`, `str_ends_with()`
- Short array syntax: `[]` not `array()`
- Strict comparisons: `===` not `==`
- PHP 8 attributes: `#[ContentEntityType(...)]` not annotations

### Step 4: Format Output

Present code in this exact structure:

```
## Drupal 11.x Compatible: [Feature Name]

**Architecture**: [Brief explanation of architectural approach - 2-3 sentences]

**Files:**
1. module_name.info.yml
2. module_name.permissions.yml
3. src/Entity/EntityName.php
[... complete file list]

---

### File: module_name.info.yml
```yaml
[complete code]
```

### File: src/Entity/EntityName.php
```php
[complete code]
```

[... all files with complete code]

---

## Installation

1. Place module in `web/modules/custom/module_name/`
2. Run `composer install` (if module has dependencies)
3. Enable: `ddev drush en module_name`
4. Clear cache: `ddev drush cr`
[... any additional steps]

## Quality Verification

> Always use `ddev` wrappers — never `vendor/bin/phpcs`, `vendor/bin/phpcbf`, or `vendor/bin/phpstan` directly (wrong standard/config).

**Auto-fix coding standards:**
```bash
ddev phpcbf web/modules/custom/module_name
```

**Check remaining violations (must be zero):**
```bash
ddev phpcs web/modules/custom/module_name
```

**Static analysis:**
```bash
ddev phpstan web/modules/custom/module_name
```

**Run unit tests only (faster):**
```bash
ddev phpunit web/modules/custom/module_name/tests/src/Unit/
```

**Run all tests — unit, kernel, functional:**
```bash
ddev phpunit web/modules/custom/module_name/tests/
```

## Usage

[Brief usage instructions]
```

### Step 5: Verify Quality — MANDATORY

After writing or modifying code, you MUST run these steps. Do NOT skip them.

**CRITICAL: Always use DDEV wrappers, never vendor binaries directly:**
- ❌ `vendor/bin/phpcs` / `vendor/bin/phpcbf` — wrong standard (PSR-12), will corrupt Drupal formatting
- ❌ `vendor/bin/phpstan` — may miss project phpstan.neon settings
- ✅ `ddev phpcs` / `ddev phpcbf` / `ddev phpstan` — correct Drupal standard and project config

**Run in this order and fix all issues:**

```bash
# 1. Auto-fix coding standard violations first
ddev phpcbf web/modules/custom/module_name

# 2. Check for remaining violations (must be zero errors)
ddev phpcs web/modules/custom/module_name

# 3. Static analysis (fix all errors; review warnings)
ddev phpstan web/modules/custom/module_name

# 4. Unit tests only (faster, no DB required)
ddev phpunit web/modules/custom/module_name/tests/src/Unit/

# 5. All tests — unit, kernel, functional (requires running site)
ddev phpunit web/modules/custom/module_name/tests/
```

**Security checklist — verify before finishing:**
- [ ] No SQL injection (query builder only, never string concatenation in queries)
- [ ] No XSS (output through `Xss::filter()`, `Html::escape()`, or Twig auto-escape)
- [ ] No CSRF gaps (forms extend `FormBase`/`ConfigFormBase` for built-in token protection)
- [ ] No command injection (never pass user input to shell commands)
- [ ] No unsafe file operations (validate paths, use Drupal's file system API)
- [ ] Access control on all routes (`_permission`, `_entity_access`, etc.)
- [ ] Access checks on all entity queries (`->accessCheck(TRUE)`)
- [ ] Sensitive config not exposed in responses or logs

**Code quality checklist:**
- [ ] No deprecated Drupal APIs
- [ ] Dependency injection used (not `\Drupal::service()` in classes)
- [ ] Cache metadata on render arrays
- [ ] Input validation and output escaping
- [ ] Translatable strings using `$this->t()`
- [ ] PSR-4 namespacing
- [ ] Test coverage for critical paths (unit, kernel, or functional as appropriate)
- [ ] All tests pass

### Step 6: Handle Uncertainty

If uncertain about an API or pattern:

1. **State uncertainty explicitly**
2. **Offer safest, officially supported alternative**
3. **Reference Drupal 11 subsystem** (e.g., "See Entity API at api.drupal.org/api/drupal/11.x")
4. **Provide multiple valid options** when applicable

Example:
> "For this use case, you have two approaches: (1) Entity Query for simple queries with automatic access checking, or (2) Database API for complex joins. Both are documented at api.drupal.org/api/drupal/11.x. I recommend Entity Query unless you need joins across non-entity tables."

## Bundled Resources

**references/** - Comprehensive Drupal 11 API documentation loaded into context when needed

- `references/dependency-injection.md` - Service container and dependency injection patterns
- `references/entity-api.md` - Entity system, content entities, config entities
- `references/plugin-api.md` - Plugin system, discovery mechanisms, derivatives
- `references/configuration-api.md` - Configuration management, schemas, overrides
- `references/cache-api.md` - Cache bins, tags, contexts, max-age
- `references/routing-system.md` - Routes, controllers, parameters, dynamic routes
- `references/form-api.md` - Form building, validation, submission, AJAX
- `references/database-api.md` - Query interface, transactions, best practices
- `references/render-theming.md` - Render arrays, theme hooks, preprocess, Twig
- `references/event-system.md` - Event subscribers, kernel events, entity events
- `references/hooks.md` - Legacy hooks still relevant in Drupal 11
- `references/security.md` - Output escaping, input validation, access control, CSRF
- `references/testing-quality.md` - Testing with PHPUnit (unit, kernel, functional tests)

Load the relevant reference file(s) when working on specific subsystems. For example:
- Creating custom entity → Load `entity-api.md`
- Implementing caching → Load `cache-api.md`
- Building forms → Load `form-api.md`
- Writing tests → Load `testing-quality.md`

**When to Reference External Examples:**
For complex implementations or when user requests "to check Drupal Examples" modules:
- Use WebFetch to retrieve specific files from the Drupal Examples project
- Especially valuable for: custom entities, plugin systems, complex forms, AJAX workflows
- See "External Resources: Drupal Examples Project" section below for URLs and patterns
- Always adapt annotation-based code to PHP 8 attributes for Drupal 11

## Examples

### Example 1: Custom Content Entity

```
User: "Create a Drupal 11 module for managing tasks with title, status, and due date fields"

Claude:
[Loads references/entity-api.md and references/dependency-injection.md]

## Drupal 11.x Compatible: Task Management Module

**Architecture**: This implementation creates a custom content entity using PHP 8 attributes for entity type definition, proper dependency injection in handlers, base field definitions for task fields, and comprehensive cache metadata for optimal performance.

**Files:**
1. task.info.yml
2. task.permissions.yml
3. task.routing.yml
4. src/Entity/Task.php
5. src/Entity/TaskInterface.php
6. src/TaskAccessControlHandler.php
7. src/TaskListBuilder.php
8. src/Form/TaskForm.php

[... complete code for all files ...]
```

### Example 2: Custom Plugin

```
User: "Implement a custom Drupal block plugin that displays recent articles"

Claude:
[Loads references/plugin-api.md and references/cache-api.md]

## Drupal 11.x Compatible: Recent Articles Block

**Architecture**: This implementation creates a custom block plugin using PHP 8 attributes for plugin definition, dependency injection for entity type manager, proper cache tags and contexts for optimal invalidation, and access checking in entity queries.

[... complete code ...]
```

### Example 3: Configuration Form

```
User: "Create a Drupal settings form for API configuration"

Claude:
[Loads references/form-api.md and references/configuration-api.md]

## Drupal 11.x Compatible: API Settings Form

**Architecture**: This implementation extends ConfigFormBase for proper configuration storage, includes configuration schema for validation, uses dependency injection for config factory, and implements proper input validation and CSRF protection.

[... complete code ...]
```

## Primary Objective

Produce Drupal 11 modules, themes, and code that:

- ✅ **Install via Composer** - Proper dependencies declared
- ✅ **Enable without warnings** - No deprecated code or errors
- ✅ **Pass code review** - Suitable for drupal.org contribution
- ✅ **Pass phpcs checks** - Clean Drupal/DrupalPractice coding standards
- ✅ **Pass phpstan checks** - Static analysis with no errors
- ✅ **Production-ready** - Secure, performant, maintainable
- ✅ **Well-documented** - Clear PHPDoc, minimal inline comments
- ✅ **Modern PHP** - PHP 8.2+ syntax, type declarations

## Staying Current with Drupal API Changes

When working with a Drupal API in an upgrade or unfamiliar context, verify against live sources before proceeding:

1. **Check breaking changes** for this Drupal version:
   Use WebFetch on `https://www.drupal.org/list-changes/drupal?version=11.x` and filter for the relevant subsystem/keyword. This page has RSS and supports version filtering.
2. **Check the live API reference** for current method signatures:
   Use WebFetch on `https://api.drupal.org/api/drupal/11.x`

The static `references/` files are the fast path for common patterns. WebFetch against these URLs is the source of truth when upgrading or when a pattern isn't covered.

---

## Quick Reference

**Always reference**: https://api.drupal.org/api/drupal/11.x

**Breaking changes**: https://www.drupal.org/list-changes/drupal?version=11.x

**Prioritize**: Security → Performance → Maintainability

**Modern PHP Required:**
- Arrow functions, null coalescing, modern string functions
- Type hints and return types
- PHP 8 attributes not annotations
- Strict comparisons (`===`)

**Drupal Patterns:**
- Dependency injection over `\Drupal::service()`
- `#[Hook]` attributes in tagged service classes (default for all hooks — see `references/hooks.md`)
- Procedural hooks only when required: `hook_theme()`, `hook_install()`, `hook_schema()`, `hook_update_N()`
- Event subscribers for Symfony kernel/routing/config events (NOT for entity CRUD — use `#[Hook]`)
- Plugin APIs over legacy systems
- Entity queries with `->accessCheck()`
- Cache metadata on render arrays

## External Resources: Drupal Examples Project

The official Drupal Examples project provides 34 working, tested modules demonstrating APIs and patterns. These serve as **secondary references** when building complex implementations.

**Project page**: https://www.drupal.org/project/examples
**Git repository**: https://git.drupalcode.org/project/examples
**Browse source**: https://git.drupalcode.org/project/examples/-/tree/4.0.x/modules?ref_type=heads

### When to Reference Examples

**For complete working implementations:**
- Use WebFetch to read specific example module files from the Git repository
- Examples provide full file structure, handlers, forms, and tests
- Especially valuable for: custom entities, plugin systems, AJAX workflows
- Browse URL pattern: `https://git.drupalcode.org/project/examples/-/tree/4.0.x/modules/{module_name}?ref_type=heads`
- Raw file URL pattern: `https://git.drupalcode.org/project/examples/-/raw/4.0.x/modules/{module_name}/{file_path}?ref_type=heads`

**Quality standards from examples:**
- Complete implementations (all required files)
- Proper dependency injection patterns
- Comprehensive test coverage (unit, kernel, functional)
- Security best practices
- Cache metadata and performance patterns

### Examples by Topic

**Entities:**
- `content_entity_example` - Full content entity with handlers, forms, list builder
- `config_entity_example` - Configuration entity with schema and management
- `field_example` - Custom field types, widgets, formatters
- `field_permission_example` - Field-level permissions

**Plugins:**
- `plugin_type_example` - Creating custom plugin types and managers
- `block_example` - Block plugins with configuration
- `queue_example` - Queue plugins for background processing

**Forms & Interaction:**
- `form_api_example` - Form building, validation, AJAX
- `ajax_example` - AJAX patterns and behaviors

**Data & Persistence:**
- `dbtng_example` - Database queries, transactions
- `config_simple_example` - Configuration API usage

**Advanced Patterns:**
- `events_example` - Event subscribers and dispatchers
- `cache_example` - Cache bins, tags, contexts
- `batch_example` - Batch API for long operations
- `cron_example` - Cron hook implementations

**Testing:**
- `testing_example` - Unit, kernel, and functional browser tests (includes PHPUnit examples)

**How to Access:**
- Browse modules: https://git.drupalcode.org/project/examples/-/tree/4.0.x/modules?ref_type=heads
- Browse specific module: `https://git.drupalcode.org/project/examples/-/tree/4.0.x/modules/{module_name}?ref_type=heads`
- Fetch raw file: `https://git.drupalcode.org/project/examples/-/raw/4.0.x/modules/{module_name}/{file_path}?ref_type=heads`

**Example URLs:**
- Browse testing_example: https://git.drupalcode.org/project/examples/-/tree/4.0.x/modules/testing_example?ref_type=heads
- Browse cache_example: https://git.drupalcode.org/project/examples/-/tree/4.0.x/modules/cache_example?ref_type=heads

**Important Notes:**
1. Examples use annotations (older style) - adapt to PHP 8 attributes for Drupal 11
2. Use WebFetch to retrieve example files when building complex patterns
3. Extract patterns but modernize syntax to Drupal 11 standards
4. Include test patterns from examples in generated modules

## Progressive Disclosure

This SKILL.md provides the core workflow and principles. Reference documentation in `references/` is loaded as needed based on the specific subsystem being worked on. This keeps the initial context light while providing deep expertise when required.
