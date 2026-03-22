# Event System

## Event Subscribers

Event subscribers replace many legacy hooks, providing object-oriented event handling using Symfony's event dispatcher.

## Basic Event Subscriber

```php
namespace Drupal\my_module\EventSubscriber;

use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\RequestEvent;
use Symfony\Component\HttpKernel\Event\ResponseEvent;
use Symfony\Component\HttpKernel\KernelEvents;

class MyModuleSubscriber implements EventSubscriberInterface {

  public static function getSubscribedEvents(): array {
    return [
      KernelEvents::REQUEST => ['onRequest', 100],
      KernelEvents::RESPONSE => ['onResponse', -100],
    ];
  }

  public function onRequest(RequestEvent $event): void {
    // Handle request
    $request = $event->getRequest();

    // Modify request
    $request->attributes->set('custom_attribute', 'value');

    // Check if main request (not subrequest)
    if (!$event->isMainRequest()) {
      return;
    }
  }

  public function onResponse(ResponseEvent $event): void {
    // Handle response
    $response = $event->getResponse();

    // Modify response
    $response->headers->set('X-Custom-Header', 'value');
  }

}
```

### Register Service

`my_module.services.yml`:

```yaml
services:
  my_module.event_subscriber:
    class: Drupal\my_module\EventSubscriber\MyModuleSubscriber
    tags:
      - { name: event_subscriber }
```

## Kernel Events

### Common Kernel Events

- `KernelEvents::REQUEST` - Before routing (priority typically > 0)
- `KernelEvents::CONTROLLER` - Before controller execution
- `KernelEvents::CONTROLLER_ARGUMENTS` - After controller is determined
- `KernelEvents::VIEW` - When controller returns non-Response value
- `KernelEvents::RESPONSE` - Before sending response (priority typically < 0)
- `KernelEvents::FINISH_REQUEST` - After response sent
- `KernelEvents::TERMINATE` - After response sent to user
- `KernelEvents::EXCEPTION` - When exception thrown

### Request Event

```php
use Symfony\Component\HttpKernel\Event\RequestEvent;
use Symfony\Component\HttpKernel\KernelEvents;

public static function getSubscribedEvents(): array {
  return [
    KernelEvents::REQUEST => ['onRequest', 0],
  ];
}

public function onRequest(RequestEvent $event): void {
  $request = $event->getRequest();

  // Get request data
  $method = $request->getMethod();
  $path = $request->getPathInfo();
  $query = $request->query->all();

  // Only for main request
  if (!$event->isMainRequest()) {
    return;
  }

  // Set custom response (stops further processing)
  if ($path === '/blocked') {
    $response = new Response('Access Denied', 403);
    $event->setResponse($response);
  }
}
```

### Response Event

```php
use Symfony\Component\HttpKernel\Event\ResponseEvent;
use Symfony\Component\HttpKernel\KernelEvents;

public static function getSubscribedEvents(): array {
  return [
    KernelEvents::RESPONSE => ['onResponse', -100],
  ];
}

public function onResponse(ResponseEvent $event): void {
  $response = $event->getResponse();

  // Add custom header
  $response->headers->set('X-Custom-Header', 'value');

  // Modify content (if HTML response)
  if ($response->headers->get('Content-Type') === 'text/html') {
    $content = $response->getContent();
    $content .= '<!-- Custom footer -->';
    $response->setContent($content);
  }
}
```

### Exception Event

```php
use Symfony\Component\HttpKernel\Event\ExceptionEvent;
use Symfony\Component\HttpKernel\KernelEvents;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

public static function getSubscribedEvents(): array {
  return [
    KernelEvents::EXCEPTION => ['onException', 0],
  ];
}

public function onException(ExceptionEvent $event): void {
  $exception = $event->getThrowable();

  // Log exception
  \Drupal::logger('my_module')->error($exception->getMessage());

  // Custom 404 handling
  if ($exception instanceof NotFoundHttpException) {
    $response = new Response('Custom 404 page', 404);
    $event->setResponse($response);
  }
}
```

## Entity Events (with Hook Event Dispatcher)

> **Drupal 11.3 Change**: Hooks are **no longer wired through the event dispatcher** internally (performance improvement — [change record](https://www.drupal.org/node/3550627)). The `hook_event_dispatcher` contrib module's approach of subscribing to hook events via the Symfony event system is therefore no longer the recommended pattern for new code. For entity CRUD reactions in new modules, implement the hook directly in a `.module` file or use a dedicated `#[Hook]` attribute (see `hooks.md`). The pattern below is shown for legacy/contrib compatibility only.

### Entity CRUD Events (legacy — hook_event_dispatcher contrib)

```php
use Drupal\Core\Entity\EntityInterface;
use Drupal\hook_event_dispatcher\HookEventDispatcherInterface;
use Drupal\hook_event_dispatcher\Event\Entity\EntityInsertEvent;
use Drupal\hook_event_dispatcher\Event\Entity\EntityUpdateEvent;
use Drupal\hook_event_dispatcher\Event\Entity\EntityDeleteEvent;

public static function getSubscribedEvents(): array {
  return [
    HookEventDispatcherInterface::ENTITY_INSERT => 'onEntityInsert',
    HookEventDispatcherInterface::ENTITY_UPDATE => 'onEntityUpdate',
    HookEventDispatcherInterface::ENTITY_DELETE => 'onEntityDelete',
  ];
}

public function onEntityInsert(EntityInsertEvent $event): void {
  $entity = $event->getEntity();

  if ($entity->getEntityTypeId() === 'node') {
    // Handle node insert
    \Drupal::logger('my_module')->notice('Node created: @title', [
      '@title' => $entity->label(),
    ]);
  }
}

public function onEntityUpdate(EntityUpdateEvent $event): void {
  $entity = $event->getEntity();
  $original = $event->getOriginal();

  if ($entity->getEntityTypeId() === 'node') {
    // Compare original and updated
    if ($entity->label() !== $original->label()) {
      // Title changed
    }
  }
}

public function onEntityDelete(EntityDeleteEvent $event): void {
  $entity = $event->getEntity();

  if ($entity->getEntityTypeId() === 'node') {
    // Handle node deletion
  }
}
```

## Route Events

### Route Alter Event

```php
use Drupal\Core\Routing\RouteBuildEvent;
use Drupal\Core\Routing\RoutingEvents;

public static function getSubscribedEvents(): array {
  return [
    RoutingEvents::ALTER => ['onRouteAlter', 0],
  ];
}

public function onRouteAlter(RouteBuildEvent $event): void {
  $collection = $event->getRouteCollection();

  // Modify existing route
  if ($route = $collection->get('user.login')) {
    $route->setPath('/signin');
  }
}
```

## Configuration Events

### Config CRUD Events

```php
use Drupal\Core\Config\ConfigEvents;
use Drupal\Core\Config\ConfigCrudEvent;

public static function getSubscribedEvents(): array {
  return [
    ConfigEvents::SAVE => 'onConfigSave',
    ConfigEvents::DELETE => 'onConfigDelete',
    ConfigEvents::RENAME => 'onConfigRename',
  ];
}

public function onConfigSave(ConfigCrudEvent $event): void {
  $config = $event->getConfig();

  if ($config->getName() === 'my_module.settings') {
    // Clear cache when settings change
    \Drupal::cache('my_custom')->deleteAll();
  }
}

public function onConfigDelete(ConfigCrudEvent $event): void {
  $config = $event->getConfig();
  // Handle config deletion
}
```

### Config Import Event

```php
use Drupal\Core\Config\ConfigImporterEvent;
use Drupal\Core\Config\ConfigEvents;

public static function getSubscribedEvents(): array {
  return [
    ConfigEvents::IMPORT => 'onConfigImport',
  ];
}

public function onConfigImport(ConfigImporterEvent $event): void {
  $importer = $event->getConfigImporter();

  // React to configuration import
  foreach ($importer->getUnprocessedConfiguration('create') as $name) {
    // Handle new configuration
  }
}
```

## Custom Events

### Define Custom Event

```php
namespace Drupal\my_module\Event;

use Drupal\Component\EventDispatcher\Event;
use Drupal\node\NodeInterface;

class CustomEvent extends Event {

  const NAME = 'my_module.custom_event';

  protected NodeInterface $node;

  public function __construct(NodeInterface $node) {
    $this->node = $node;
  }

  public function getNode(): NodeInterface {
    return $this->node;
  }

}
```

### Dispatch Custom Event

```php
use Drupal\my_module\Event\CustomEvent;
use Symfony\Component\EventDispatcher\EventDispatcherInterface;

public function __construct(EventDispatcherInterface $event_dispatcher) {
  $this->eventDispatcher = $event_dispatcher;
}

public function myMethod(NodeInterface $node): void {
  // Dispatch event
  $event = new CustomEvent($node);
  $this->eventDispatcher->dispatch($event, CustomEvent::NAME);
}
```

### Subscribe to Custom Event

```php
use Drupal\my_module\Event\CustomEvent;

public static function getSubscribedEvents(): array {
  return [
    CustomEvent::NAME => 'onCustomEvent',
  ];
}

public function onCustomEvent(CustomEvent $event): void {
  $node = $event->getNode();
  // Handle custom event
}
```

## Event Priorities

Events are processed in order of priority (highest to lowest):

```php
public static function getSubscribedEvents(): array {
  return [
    // Runs early (before most others)
    KernelEvents::REQUEST => ['onRequest', 100],

    // Runs at normal priority
    KernelEvents::REQUEST => ['onRequest', 0],

    // Runs late (after most others)
    KernelEvents::RESPONSE => ['onResponse', -100],
  ];
}
```

**Priority guidelines:**
- **> 100**: Very early (should rarely be used)
- **10 to 100**: Early
- **0**: Normal (default)
- **-10 to -100**: Late
- **< -100**: Very late (should rarely be used)

## Dependency Injection in Event Subscribers

```php
namespace Drupal\my_module\EventSubscriber;

use Drupal\Core\Entity\EntityTypeManagerInterface;
use Drupal\Core\Logger\LoggerChannelFactoryInterface;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;

class MySubscriber implements EventSubscriberInterface {

  protected EntityTypeManagerInterface $entityTypeManager;
  protected LoggerChannelFactoryInterface $loggerFactory;

  public function __construct(
    EntityTypeManagerInterface $entity_type_manager,
    LoggerChannelFactoryInterface $logger_factory
  ) {
    $this->entityTypeManager = $entity_type_manager;
    $this->loggerFactory = $logger_factory;
  }

  public static function create(ContainerInterface $container): static {
    return new static(
      $container->get('entity_type.manager'),
      $container->get('logger.factory')
    );
  }

  public static function getSubscribedEvents(): array {
    return [
      KernelEvents::REQUEST => ['onRequest', 0],
    ];
  }

  // Event handlers...
}
```

**Service definition with arguments**:

```yaml
services:
  my_module.event_subscriber:
    class: Drupal\my_module\EventSubscriber\MySubscriber
    arguments:
      - '@entity_type.manager'
      - '@logger.factory'
    tags:
      - { name: event_subscriber }
```

## Best Practices

1. **Use appropriate event priority** - Higher runs earlier
2. **Check isMainRequest()** in REQUEST events to avoid subrequests
3. **Use dependency injection** for services
4. **Log important events** for debugging
5. **Don't stop event propagation** unless absolutely necessary
6. **Use typed event classes** for custom events
7. **Document event subscribers** clearly
8. **Test event subscribers** with appropriate priorities
9. **Keep event handlers focused** - one responsibility per method
10. **Use events over hooks** when possible for better OOP

## When to Use Events vs Hooks

**Use Events when:**
- Working with request/response cycle
- Need priority-based ordering
- Better dependency injection support
- More object-oriented approach preferred

**Use Hooks when:**
- Simple entity alterations
- Form alterations
- Theme system integration
- No suitable event exists
