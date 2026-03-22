# Dependency Injection & Service Container

## Core Concepts

The service container implements dependency injection patterns from Symfony. Services are reusable components (database access, email sending, translations) defined by unique names and interfaces.

**Key Principle**: Classes should instantiate services through the container rather than directly, allowing default implementations to be overridden without changing dependent code.

## Service Definition

Services are declared in `*.services.yml` files:

```yaml
services:
  my_module.custom_service:
    class: Drupal\my_module\Service\CustomService
    arguments:
      - '@entity_type.manager'
      - '@current_user'
      - '@logger.factory'
    tags:
      - { name: 'event_subscriber' }
```

**Service Components:**
- **Machine name**: Unique identifier (typically module-prefixed)
- **Class**: Implementation or interface
- **Arguments**: Dependencies preceded by `@` symbol
- **Tags**: Categorize services for batch operations

## Accessing Services

**Three Methods (in order of preference):**

### 1. Constructor Injection (PREFERRED)

Pass services as constructor arguments:

```php
namespace Drupal\my_module\Controller;

use Drupal\Core\Controller\ControllerBase;
use Drupal\Core\Entity\EntityTypeManagerInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;

class MyController extends ControllerBase {

  protected EntityTypeManagerInterface $entityTypeManager;

  public function __construct(EntityTypeManagerInterface $entity_type_manager) {
    $this->entityTypeManager = $entity_type_manager;
  }

  public static function create(ContainerInterface $container) {
    return new static(
      $container->get('entity_type.manager')
    );
  }

}
```

### 2. Service Location

When DI isn't possible:

```php
$manager = \Drupal::entityTypeManager();
$service = \Drupal::service('custom.service');
```

### 3. Autowiring

Container automatically resolves constructor type-hints (advanced usage).

## Why Dependency Injection?

- **Simplifies unit testing** - Dependencies are mockable
- **Improves IDE auto-completion** - Type hints provide better developer experience
- **Makes dependencies explicit** - Class requirements are self-documenting
- **Reduces coupling** - Less reliance on global container

## Overriding Services

Implement `ServiceProviderBase` to replace default service classes:

```php
namespace Drupal\my_module;

use Drupal\Core\DependencyInjection\ContainerBuilder;
use Drupal\Core\DependencyInjection\ServiceProviderBase;

class MyModuleServiceProvider extends ServiceProviderBase {

  public function alter(ContainerBuilder $container) {
    $definition = $container->getDefinition('service.name');
    $definition->setClass('Drupal\my_module\CustomClass');
  }

}
```

## Common Services

- `entity_type.manager` - EntityTypeManagerInterface
- `current_user` - AccountProxyInterface
- `logger.factory` - LoggerChannelFactoryInterface
- `config.factory` - ConfigFactoryInterface
- `database` - Connection
- `messenger` - MessengerInterface
- `date.formatter` - DateFormatterInterface
- `path.validator` - PathValidatorInterface
- `module_handler` - ModuleHandlerInterface
- `theme_handler` - ThemeHandlerInterface
