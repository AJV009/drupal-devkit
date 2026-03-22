# Drupal Documentation URL Catalog

A curated collection of essential drupal.org and api.drupal.org documentation URLs for AI-assisted Drupal development.

---

## Core APIs

- https://www.drupal.org/docs/drupal-apis — APIs overview. Master index of all Drupal core APIs with descriptions and links.
- https://www.drupal.org/docs/drupal-apis/entity-api — Entity API. Creating, loading, updating, and querying content and configuration entities.
- https://www.drupal.org/docs/drupal-apis/entity-api/content-entities — Content entities. Defining custom content entity types with base fields and bundles.
- https://www.drupal.org/docs/drupal-apis/entity-api/configuration-entities — Configuration entities. Defining exportable configuration entity types.
- https://www.drupal.org/docs/drupal-apis/form-api — Form API. Building, validating, and processing forms with render arrays and form classes.
- https://www.drupal.org/docs/drupal-apis/form-api/ajax-forms — AJAX forms. Adding AJAX behaviors to forms, AJAX callbacks, and command responses.
- https://www.drupal.org/docs/drupal-apis/render-api — Render API. Render arrays, render elements, #theme hooks, and the rendering pipeline.
- https://www.drupal.org/docs/drupal-apis/render-api/render-arrays — Render arrays. Structure, properties, and element types for Drupal render arrays.
- https://www.drupal.org/docs/drupal-apis/routing-system — Routing system. Defining routes in YAML, route parameters, controllers, and access checking.
- https://www.drupal.org/docs/drupal-apis/routing-system/access-checking-on-routes — Route access checking. Permission-based, role-based, and custom access checkers.
- https://www.drupal.org/docs/drupal-apis/services-and-dependency-injection — Services and dependency injection. The service container, service definitions, and injecting dependencies.
- https://www.drupal.org/docs/drupal-apis/plugin-api — Plugin API. Plugin types, plugin managers, annotations, attributes, and plugin discovery.
- https://www.drupal.org/docs/drupal-apis/cache-api — Cache API. Cache bins, cache tags, cache contexts, and max-age for cache invalidation.
- https://www.drupal.org/docs/drupal-apis/database-api — Database API. Database abstraction layer, query builders, schema API, and migrations.
- https://www.drupal.org/docs/drupal-apis/javascript-api — JavaScript API. Drupal behaviors, jQuery integration, once(), Ajax framework, and drupalSettings.
- https://www.drupal.org/docs/drupal-apis/javascript-api/ajax-api — AJAX API. Ajax commands, Ajax links and forms, client-side AJAX framework.
- https://www.drupal.org/docs/drupal-apis/state-api — State API. Storing transient data that is environment-specific using the state system.
- https://www.drupal.org/docs/drupal-apis/batch-api — Batch API. Processing large operations in chunks across multiple HTTP requests.
- https://www.drupal.org/docs/drupal-apis/queue-api — Queue API. Creating and processing asynchronous task queues with workers.
- https://www.drupal.org/docs/drupal-apis/update-api — Update API. Hook_update_N functions for schema and data updates between releases.
- https://www.drupal.org/docs/drupal-apis/migrate-api — Migrate API. Source plugins, process plugins, and destination plugins for data migration.
- https://www.drupal.org/docs/drupal-apis/typed-data-api — Typed Data API. Data type definitions, data validation, and typed data objects.

## Hooks and Events

- https://www.drupal.org/docs/drupal-apis/hooks — Hooks system. Overview of the hook system, hook invocation, and implementing hooks in modules.
- https://www.drupal.org/docs/drupal-apis/hooks/hooks-and-events — Hooks and events. Using Symfony event subscribers alongside traditional Drupal hooks.
- https://api.drupal.org/api/drupal/core!lib!Drupal!Core!Entity!entity.api.php/group/entity_api_hooks/11.x — Entity API hooks reference. Complete list of entity hooks (presave, insert, update, delete, load, view, access).

## Module Development

- https://www.drupal.org/docs/develop/creating-modules — Creating modules. Step-by-step guide to building a custom Drupal module from scratch.
- https://www.drupal.org/docs/develop/creating-modules/let-drupal-know-about-your-module-with-an-infoyml-file — Module info.yml. Defining module metadata, dependencies, and requirements in info.yml.
- https://www.drupal.org/docs/develop/creating-modules/adding-a-controller — Adding a controller. Creating page controllers, returning responses, and route-controller mapping.
- https://www.drupal.org/docs/develop/creating-modules/creating-custom-blocks — Creating custom blocks. Block plugin development with annotations, configuration forms, and build methods.
- https://www.drupal.org/docs/develop/creating-modules/adding-a-service — Adding a service. Defining services in module.services.yml and injecting dependencies.

## Theming and Frontend

- https://www.drupal.org/docs/develop/theming-drupal — Theming Drupal. Theme structure, template files, theme hooks, libraries, and asset management.
- https://www.drupal.org/docs/develop/theming-drupal/twig-in-drupal — Twig in Drupal. Twig template syntax, filters, functions, and Drupal-specific extensions.
- https://www.drupal.org/docs/develop/theming-drupal/adding-assets-css-js-to-a-drupal-module-or-theme — Adding assets. Defining CSS and JavaScript libraries in *.libraries.yml and attaching them.
- https://www.drupal.org/docs/develop/theming-drupal/creating-sub-themes — Creating sub-themes. Inheriting from a base theme and overriding templates and styles.
- https://www.drupal.org/docs/develop/theming-drupal/single-directory-components — Single Directory Components (SDC). Component-based theming with co-located templates, CSS, JS, and schemas.

## Coding Standards and Best Practices

- https://www.drupal.org/docs/develop/standards — Coding standards. PHP, CSS, JavaScript, and Twig coding standards for Drupal projects.
- https://www.drupal.org/docs/develop/standards/php-coding-standards — PHP coding standards. Formatting, naming conventions, documentation, and code organization rules.
- https://www.drupal.org/docs/develop/security-in-drupal — Security best practices. Sanitization, access checking, CSRF protection, and security advisories.

## Testing

- https://www.drupal.org/docs/develop/automated-testing — Automated testing. Overview of testing frameworks, test types, and running tests in Drupal.
- https://www.drupal.org/docs/develop/automated-testing/phpunit-in-drupal — PHPUnit in Drupal. Unit tests, kernel tests, functional tests, and FunctionalJavascript tests.
- https://www.drupal.org/docs/develop/automated-testing/nightwatch — Nightwatch testing. End-to-end JavaScript testing with Nightwatch.js for Drupal.

## Configuration Management

- https://www.drupal.org/docs/configuration-management — Configuration management. Exporting, importing, and synchronizing site configuration between environments.
- https://www.drupal.org/docs/configuration-management/managing-your-sites-configuration — Managing site configuration. Workflows for config export/import, config split, and deployment.

## Extending Drupal

- https://www.drupal.org/docs/extending-drupal — Extending Drupal. Finding, evaluating, installing, and configuring contributed modules and themes.
- https://www.drupal.org/docs/extending-drupal/installing-modules — Installing modules. Installing contributed modules via Composer and enabling them.
- https://www.drupal.org/docs/distributions — Distributions. Pre-configured Drupal packages for specific use cases and site profiles.

## User Guide and Administration

- https://www.drupal.org/docs/user-guide — User guide. Comprehensive guide covering Drupal installation, configuration, content management, and administration.
- https://www.drupal.org/docs/administering-a-drupal-site — Administering a Drupal site. Cron, logging, performance tuning, and site maintenance.
- https://www.drupal.org/docs/user-guide/en/security-chapter — Security chapter. User roles, permissions, and securing a Drupal installation.

## API Reference (api.drupal.org)

- https://api.drupal.org/api/drupal/11.x — Drupal 11 API reference. Complete auto-generated API documentation for all Drupal 11 core classes, functions, and interfaces.
- https://api.drupal.org/api/drupal/core!core.api.php/group/hooks/11.x — Hooks reference. Full list of hooks defined in Drupal 11 core with signatures and documentation.
- https://api.drupal.org/api/drupal/core!lib!Drupal.php/class/Drupal/11.x — Drupal static class. The global Drupal class providing static service accessors (deprecated pattern but widely referenced).
- https://api.drupal.org/api/drupal/core!lib!Drupal!Core!Entity!EntityInterface.php/interface/EntityInterface/11.x — EntityInterface. Base interface for all entity objects with methods for CRUD, access, and URL generation.

## Change Records and Deprecations

- https://www.drupal.org/list-changes/drupal — Core change records. Breaking changes, deprecations, and API updates across Drupal core versions.
- https://www.drupal.org/about/core/policies/core-change-policies — Core change policies. Rules governing what changes are allowed in minor, patch, and major releases.

## Composer and Dependency Management

- https://www.drupal.org/docs/develop/using-composer — Using Composer with Drupal. Managing Drupal projects, dependencies, patches, and scaffolding with Composer.
- https://www.drupal.org/docs/develop/using-composer/manage-dependencies — Managing dependencies. Adding, updating, and removing packages in a Drupal Composer project.
