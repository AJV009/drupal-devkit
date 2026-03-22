# Configuration API

## Core Concepts

The Configuration API provides methods for storing information with separation of concerns by abstracting storage details from module developers.

**Active Configuration**: Currently in use on a site. Storage can be database, file system, or alternative backends (database is default).

## Simple Configuration

### Read-only Access

```php
$config = \Drupal::config('my_module.settings');
$api_key = $config->get('api_key');
$nested = $config->get('server.host');
```

### Editable Configuration

```php
$config = \Drupal::configFactory()->getEditable('my_module.settings');
$config->set('api_key', 'new_value')
  ->set('server.host', 'example.com')
  ->save();
```

### With Dependency Injection

```php
use Drupal\Core\Config\ConfigFactoryInterface;

public function __construct(ConfigFactoryInterface $config_factory) {
  $this->configFactory = $config_factory;
}

public static function create(ContainerInterface $container) {
  return new static(
    $container->get('config.factory')
  );
}

public function myMethod() {
  $config = $this->configFactory->getEditable('my_module.settings');
  $config->set('key', 'value')->save();
}
```

## Configuration Schema

### Schema Definition

**Location**: `config/schema/my_module.schema.yml`

```yaml
my_module.settings:
  type: config_object
  label: 'My Module settings'
  mapping:
    api_key:
      type: string
      label: 'API Key'
    server:
      type: mapping
      label: 'Server configuration'
      mapping:
        host:
          type: string
          label: 'Host'
        port:
          type: integer
          label: 'Port'
    enabled:
      type: boolean
      label: 'Enabled'
    features:
      type: sequence
      label: 'Features'
      sequence:
        type: string
```

### Data Types

- `string` - Non-translatable text
- `text` - Translatable text
- `label` - Translatable label
- `integer` - Integer value
- `float` - Float value
- `boolean` - Boolean value
- `email` - Email address
- `uri` - URI
- `date_format` - Date format string
- `mapping` - Nested structure (object)
- `sequence` - Array of items (list)

## Default Configuration

### Install Configuration

**Location**: `config/install/my_module.settings.yml`

```yaml
api_key: 'default_key'
server:
  host: 'localhost'
  port: 8080
enabled: true
features:
  - feature_one
  - feature_two
```

This configuration is installed when the module is first enabled.

### Optional Configuration

**Location**: `config/optional/my_module.optional_settings.yml`

Configuration that is only installed if dependencies are met.

## Configuration Entities

### Entity Definition

Each config entity requires a corresponding schema:

```php
#[ConfigEntityType(
  id: 'robot',
  config_prefix: 'robot',
  // ... handlers, links, etc.
)]
```

### Schema for Config Entity

`my_module.schema.yml`:

```yaml
my_module.robot.*:
  type: config_entity
  label: 'Robot configuration'
  mapping:
    id:
      type: string
      label: 'ID'
    label:
      type: label
      label: 'Label'
    model:
      type: string
      label: 'Model'
    settings:
      type: mapping
      label: 'Settings'
      mapping:
        speed:
          type: integer
          label: 'Speed'
        autonomous:
          type: boolean
          label: 'Autonomous mode'
```

## Configuration Management

### Export Configuration

```bash
ddev drush config:export
# or
ddev drush cex
```

Exports active configuration to sync directory (`config/sync/`).

### Import Configuration

```bash
ddev drush config:import
# or
ddev drush cim
```

Imports configuration from sync directory to active storage.

### Configuration Workflow

1. **Development**: Make changes via UI or code
2. **Export**: `drush cex` to export to YAML files
3. **Version Control**: Commit YAML files to git
4. **Deployment**: Pull code, run `drush cim` to import
5. **Rebuild Cache**: `drush cr`

## Configuration Overrides

### In settings.php

Override configuration values per environment:

```php
$config['system.site']['name'] = 'Production Site';
$config['my_module.settings']['api_key'] = 'production_key';
```

**Important**: Overrides in `settings.php` are NOT exported or imported. They are environment-specific.

### Getting Original vs Override

```php
// Get overridden value
$value = \Drupal::config('my_module.settings')->get('api_key');

// Get original (non-overridden) value
$value = \Drupal::config('my_module.settings')
  ->getOriginal('api_key', FALSE);
```

## Configuration Events

### Config Events

```php
use Drupal\Core\Config\ConfigEvents;
use Drupal\Core\Config\ConfigCrudEvent;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;

class ConfigSubscriber implements EventSubscriberInterface {

  public static function getSubscribedEvents() {
    return [
      ConfigEvents::SAVE => 'onConfigSave',
      ConfigEvents::DELETE => 'onConfigDelete',
    ];
  }

  public function onConfigSave(ConfigCrudEvent $event) {
    $config = $event->getConfig();
    if ($config->getName() === 'my_module.settings') {
      // React to configuration change
    }
  }

}
```

## Best Practices

1. **Always define schema** for your configuration
2. **Use dependency injection** for ConfigFactory
3. **Use `getEditable()`** only when writing configuration
4. **Provide default values** in `config/install/`
5. **Export configuration** after making changes
6. **Use environment-specific overrides** in `settings.php`
7. **Never store secrets** in exportable configuration (use `settings.php` instead)
8. **Use translatable types** (`text`, `label`) for user-facing strings
9. **Validate configuration** using schema
10. **Use mapping for nested structures**, sequence for arrays
11. **NEVER include `uuid` fields** in manually created config files - Drupal generates these automatically

## UUID Handling in Configuration Files

**IMPORTANT**: When manually creating configuration YAML files, **never include the `uuid` field**. Drupal automatically generates UUIDs when configuration is first imported.

### Why This Matters

If you include a placeholder like `uuid: TBD` or any invalid UUID:
- The literal string gets stored as the UUID value
- This causes issues with configuration management
- Configuration exports will contain invalid UUIDs

### Correct Workflow

1. **Create config files WITHOUT uuid**:
```yaml
# config/install/my_module.settings.yml
# NO uuid field here - Drupal will generate it
api_key: 'default_key'
server:
  host: 'localhost'
  port: 8080
```

2. **Import the configuration**:
```bash
ddev drush cim
```

3. **Export to capture generated UUIDs**:
```bash
ddev drush cex
```

4. **Commit the exported files** (which now include valid UUIDs)

### Fields to Omit

When creating config files manually, omit these auto-generated fields:
- `uuid` - Always generated by Drupal
- `_core` - Internal Drupal metadata

These will be added automatically when you export configuration after import.
