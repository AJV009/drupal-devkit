# Routing System

## Route Definition

**File**: `my_module.routing.yml`

```yaml
my_module.hello:
  path: '/hello/{name}'
  defaults:
    _controller: '\Drupal\my_module\Controller\HelloController::content'
    _title: 'Hello'
    name: 'World'
  requirements:
    _permission: 'access content'
    name: '[a-zA-Z]+'
  options:
    parameters:
      name:
        type: string
```

## Route Components

### Path

URL pattern (case-insensitive by default):

- **Placeholders**: `{parameter_name}`
- **Optional parameters**: `{parameter?}`
- **Static paths**: `/admin/config/my-module`

### Defaults

- `_controller`: Controller method (`'\Drupal\my_module\Controller\MyController::method'`)
- `_form`: Form class (`'\Drupal\my_module\Form\MyForm'`)
- `_entity_form`: Entity form (`'node.default'`, `'node.edit'`, `'node.delete'`)
- `_entity_view`: Entity view (`'node.full'`, `'node.teaser'`)
- `_entity_list`: Entity list builder
- `_title`: Page title (static string)
- `_title_callback`: Dynamic title callback
- Default parameter values

### Requirements

Access control and parameter validation:

- `_permission`: Permission name (`'access content'`, `'administer nodes'`)
- `_role`: Required role (`'administrator'`, `'editor'`)
- `_access`: TRUE/FALSE (always allow/deny)
- `_custom_access`: Custom access checker (`'\Drupal\my_module\Access\MyAccessChecker::access'`)
- `_csrf_token`: CSRF protection (TRUE)
- `_entity_access`: Entity access (`'node.view'`, `'node.update'`, `'node.delete'`)
- Parameter regex patterns (e.g., `node: '\d+'` for numeric only)

### Options

Route-specific options:

- `parameters`: Parameter type conversion
- `no_cache`: Disable caching — must be boolean `true` (not the string `'TRUE'`)
- `_admin_route`: Use admin theme (TRUE)
- `_auth`: Authentication methods (`['basic_auth', 'cookie']`)
- `_maintenance_access`: Allow during maintenance mode

## Entity Routes

### Entity View Route

```yaml
my_module.task.canonical:
  path: '/task/{task}'
  defaults:
    _entity_view: 'task.full'
    _title_callback: '\Drupal\my_module\Controller\TaskController::title'
  requirements:
    _entity_access: 'task.view'
  options:
    parameters:
      task:
        type: 'entity:task'
```

### Entity Form Routes

```yaml
my_module.task.add:
  path: '/task/add'
  defaults:
    _entity_form: 'task.add'
    _title: 'Add Task'
  requirements:
    _entity_create_access: 'task'

my_module.task.edit:
  path: '/task/{task}/edit'
  defaults:
    _entity_form: 'task.edit'
    _title: 'Edit Task'
  requirements:
    _entity_access: 'task.update'
  options:
    parameters:
      task:
        type: 'entity:task'

my_module.task.delete:
  path: '/task/{task}/delete'
  defaults:
    _entity_form: 'task.delete'
    _title: 'Delete Task'
  requirements:
    _entity_access: 'task.delete'
  options:
    parameters:
      task:
        type: 'entity:task'
```

### Entity Collection Route

```yaml
my_module.task.collection:
  path: '/admin/content/task'
  defaults:
    _entity_list: 'task'
    _title: 'Tasks'
  requirements:
    _permission: 'administer task entities'
```

## Controllers

### Basic Controller

```php
namespace Drupal\my_module\Controller;

use Drupal\Core\Controller\ControllerBase;
use Symfony\Component\HttpFoundation\Request;

class HelloController extends ControllerBase {

  public function content(string $name = 'World'): array {
    return [
      '#markup' => $this->t('Hello @name!', ['@name' => $name]),
      '#cache' => [
        'contexts' => ['url.path'],
      ],
    ];
  }

}
```

### Controller with Dependency Injection

```php
namespace Drupal\my_module\Controller;

use Drupal\Core\Controller\ControllerBase;
use Drupal\Core\Entity\EntityTypeManagerInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;

class TaskController extends ControllerBase {

  protected EntityTypeManagerInterface $entityTypeManager;

  public function __construct(EntityTypeManagerInterface $entity_type_manager) {
    $this->entityTypeManager = $entity_type_manager;
  }

  public static function create(ContainerInterface $container): static {
    return new static(
      $container->get('entity_type.manager')
    );
  }

  public function list(): array {
    $storage = $this->entityTypeManager->getStorage('task');
    $query = $storage->getQuery()
      ->accessCheck(TRUE)
      ->sort('created', 'DESC')
      ->range(0, 10);
    $ids = $query->execute();
    $tasks = $storage->loadMultiple($ids);

    $items = [];
    foreach ($tasks as $task) {
      $items[] = $task->label();
    }

    return [
      '#theme' => 'item_list',
      '#items' => $items,
      '#cache' => [
        'tags' => ['task_list'],
        'contexts' => ['user.permissions'],
      ],
    ];
  }

}
```

## Route Parameters

### URL Parameters

Parameters from the URL path are automatically passed to controller methods:

```yaml
# Route
my_module.user_tasks:
  path: '/user/{user}/tasks/{status}'
  defaults:
    _controller: '\Drupal\my_module\Controller\TaskController::userTasks'
```

```php
// Controller
public function userTasks(string $user, string $status): array {
  // $user and $status are automatically injected from URL
}
```

### Entity Parameters (Upcasting)

Entities are automatically loaded and type-hinted:

```yaml
# Route
my_module.task.view:
  path: '/task/{task}'
  defaults:
    _controller: '\Drupal\my_module\Controller\TaskController::view'
  options:
    parameters:
      task:
        type: 'entity:task'
```

```php
use Drupal\my_module\Entity\TaskInterface;

// Controller
public function view(TaskInterface $task): array {
  // $task is automatically loaded from {task} parameter
  return [
    '#markup' => $task->getTitle(),
  ];
}
```

### Special Parameters

These can be type-hinted in any controller method:

- `Request $request` - Symfony request object
- `RouteMatchInterface $route_match` - Route match data
- `AccountInterface $account` - Current user account

```php
use Symfony\Component\HttpFoundation\Request;
use Drupal\Core\Routing\RouteMatchInterface;
use Drupal\Core\Session\AccountInterface;

public function myMethod(
  Request $request,
  RouteMatchInterface $route_match,
  AccountInterface $account
): array {
  $query_param = $request->query->get('param');
  $route_name = $route_match->getRouteName();
  $user_id = $account->id();

  // ...
}
```

## Dynamic Routes

### Route Subscriber

For programmatically altering or adding routes:

```php
namespace Drupal\my_module\Routing;

use Drupal\Core\Routing\RouteSubscriberBase;
use Symfony\Component\Routing\RouteCollection;

class MyModuleRouteSubscriber extends RouteSubscriberBase {

  protected function alterRoutes(RouteCollection $collection) {
    // Alter existing route
    if ($route = $collection->get('user.login')) {
      $route->setPath('/signin');
    }

    // Change route requirement
    if ($route = $collection->get('node.add')) {
      $route->setRequirement('_permission', 'create content');
    }
  }

}
```

**Service Definition** (`my_module.services.yml`):

```yaml
services:
  my_module.route_subscriber:
    class: Drupal\my_module\Routing\MyModuleRouteSubscriber
    tags:
      - { name: event_subscriber }
```

### Route Provider

For generating routes dynamically (e.g., for config entities):

```php
namespace Drupal\my_module\Routing;

use Drupal\Core\Entity\EntityTypeInterface;
use Drupal\Core\Entity\Routing\EntityRouteProviderInterface;
use Symfony\Component\Routing\Route;
use Symfony\Component\Routing\RouteCollection;

class RobotRouteProvider implements EntityRouteProviderInterface {

  public function getRoutes(EntityTypeInterface $entity_type): RouteCollection {
    $collection = new RouteCollection();

    $route = new Route('/admin/structure/robot/{robot}/duplicate');
    $route->setDefaults([
      '_controller' => '\Drupal\my_module\Controller\RobotController::duplicate',
      '_title' => 'Duplicate Robot',
    ]);
    $route->setRequirement('_permission', 'administer robots');
    $collection->add('entity.robot.duplicate', $route);

    return $collection;
  }

}
```

## Access Control

### Permission-based Access

```yaml
requirements:
  _permission: 'access content'
  # OR
  _permission: 'access content+edit own content' # Requires BOTH
```

### Role-based Access

```yaml
requirements:
  _role: 'administrator'
  # OR
  _role: 'administrator+editor' # Requires BOTH roles
```

### Entity Access

```yaml
requirements:
  _entity_access: 'node.view'
  # OR
  _entity_access: 'node.update'
  # OR
  _entity_access: 'node.delete'
```

### Custom Access Checker

```yaml
requirements:
  _custom_access: '\Drupal\my_module\Access\MyAccessChecker::access'
```

```php
namespace Drupal\my_module\Access;

use Drupal\Core\Access\AccessResult;
use Drupal\Core\Routing\Access\AccessInterface;
use Drupal\Core\Session\AccountInterface;

class MyAccessChecker implements AccessInterface {

  public function access(AccountInterface $account) {
    // Custom logic
    $has_access = $account->id() > 0 && $account->hasPermission('access content');

    return AccessResult::allowedIf($has_access)
      ->cachePerUser()
      ->addCacheableDependency($account);
  }

}
```

**Service Definition**:

```yaml
services:
  my_module.access_checker:
    class: Drupal\my_module\Access\MyAccessChecker
    tags:
      - { name: access_check, applies_to: _custom_access }
```

## Title Callbacks

### Static Title

```yaml
defaults:
  _title: 'My Page'
```

### Dynamic Title Callback

```yaml
defaults:
  _title_callback: '\Drupal\my_module\Controller\MyController::getTitle'
```

```php
public function getTitle(TaskInterface $task): string {
  return $this->t('Task: @title', ['@title' => $task->getTitle()]);
}
```

## Best Practices

1. **Use entity routes** for entity operations
2. **Type-hint parameters** for automatic upcasting
3. **Include access checks** on all routes
4. **Use dependency injection** in controllers
5. **Add cache metadata** to all render arrays
6. **Use route parameters** instead of query parameters where possible
7. **Group related routes** with common path prefixes
8. **Use RouteSubscriber** for altering existing routes
9. **Cache access results** with proper dependencies
10. **Use translatable strings** for titles
