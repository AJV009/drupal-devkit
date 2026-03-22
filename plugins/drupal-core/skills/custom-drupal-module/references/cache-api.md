# Cache API

## Core Concepts

The Cache API stores computationally expensive data either permanently or within specified timeframes to improve performance.

## Cache Bins

Separate storage bins, independently configurable:

- **bootstrap**: Minimal data needed throughout requests
- **render**: HTML strings (pages, blocks)
- **data**: Context-dependent information
- **discovery**: Plugin and YAML discovery
- **memory**: In-memory static cache (per-request only)

### Define Custom Bin

In `my_module.services.yml`:

```yaml
cache.my_custom:
  class: Drupal\Core\Cache\CacheBackendInterface
  tags:
    - { name: cache.bin }
  factory: cache_factory:get
  arguments: [my_custom]
```

## Cache Operations

### Get/Set

```php
$cache = \Drupal::cache('my_custom');

// Get
$cached = $cache->get('my_cache_id');
if ($cached) {
  $data = $cached->data;
}

// Set with permanent storage
$cache->set('my_cache_id', $data, Cache::PERMANENT);

// Set with expiration (Unix timestamp)
$cache->set('my_cache_id', $data, time() + 3600);
```

### With Dependency Injection

```php
use Drupal\Core\Cache\CacheBackendInterface;

public function __construct(CacheBackendInterface $cache) {
  $this->cache = $cache;
}

public static function create(ContainerInterface $container) {
  return new static(
    $container->get('cache.my_custom')
  );
}
```

## Cache Tags

Tags identify data dependencies using `[prefix]:[suffix]` convention.

### Setting Tags

```php
use Drupal\Core\Cache\Cache;

// Set with tags
$cache->set('my_id', $data, Cache::PERMANENT, ['node:1', 'user:5']);

// In render arrays
$build = [
  '#markup' => $content,
  '#cache' => [
    'tags' => ['node:' . $node->id(), 'node_list'],
  ],
];
```

### Invalidating Tags

```php
use Drupal\Core\Cache\Cache;

// Invalidate by tag
Cache::invalidateTags(['node:1']);

// Invalidate multiple tags
Cache::invalidateTags(['node:1', 'node_list', 'user:5']);
```

### Common Tag Patterns

- `node:NID` - Specific node (e.g., `node:123`)
- `user:UID` - Specific user (e.g., `user:1`)
- `taxonomy_term:TID` - Specific taxonomy term
- `node_list` - Any node list
- `user_list` - Any user list
- `config:CONFIG_NAME` - Configuration object (e.g., `config:system.site`)
- `node_type:TYPE` - Content type (e.g., `node_type:article`)
- `rendered` - All rendered output

## Cache Contexts

Contextual variations require separate cached datasets based on user roles, language, theme, etc.

### Common Contexts

- `user` - Varies by user account (user ID)
- `user.roles` - Varies by user roles
- `user.permissions` - Varies by user permissions
- `url` - Varies by full URL (path + query)
- `url.path` - Varies by path only
- `url.query_args` - Varies by query parameters
- `url.query_args:KEY` - Varies by specific query parameter
- `languages` - Varies by all language types
- `languages:language_interface` - Varies by UI language
- `languages:language_content` - Varies by content language
- `theme` - Varies by theme
- `timezone` - Varies by timezone
- `route` - Varies by route name
- `route.name` - Same as route

### Using Contexts

```php
$build = [
  '#markup' => $content,
  '#cache' => [
    'contexts' => ['user.roles', 'url.path', 'languages:language_interface'],
  ],
];
```

### Custom Cache Contexts

Define in `my_module.services.yml`:

```php
services:
  cache_context.my_custom:
    class: Drupal\my_module\Cache\MyCustomCacheContext
    arguments: ['@current_user']
    tags:
      - { name: cache.context }
```

Implement context:

```php
namespace Drupal\my_module\Cache;

use Drupal\Core\Cache\CacheableMetadata;
use Drupal\Core\Cache\Context\CacheContextInterface;
use Drupal\Core\Session\AccountProxyInterface;

class MyCustomCacheContext implements CacheContextInterface {

  protected AccountProxyInterface $currentUser;

  public function __construct(AccountProxyInterface $current_user) {
    $this->currentUser = $current_user;
  }

  public static function getLabel() {
    return t('My Custom Context');
  }

  public function getContext() {
    // Return string that varies by your context
    return $this->currentUser->hasPermission('access content') ? 'has-access' : 'no-access';
  }

  public function getCacheableMetadata() {
    return new CacheableMetadata();
  }

}
```

## Cache Max-Age

Time-based invalidation in seconds.

### Setting Max-Age

```php
use Drupal\Core\Cache\Cache;

$build = [
  '#markup' => $content,
  '#cache' => [
    'max-age' => 3600, // 1 hour
    // 'max-age' => Cache::PERMANENT, // Never expires (default)
    // 'max-age' => 0, // Never cache (dynamic content)
  ],
];
```

### Max-Age Values

- `Cache::PERMANENT` - Cache indefinitely (until tags invalidated)
- `0` - Do not cache (always regenerate)
- Positive integer - Number of seconds to cache

### Merging Max-Age

When combining multiple cache metadata, the lowest max-age wins:

```php
use Drupal\Core\Cache\Cache;

$max_age = Cache::mergeMaxAges(3600, 7200); // Result: 3600
$max_age = Cache::mergeMaxAges(3600, 0); // Result: 0
```

## Complete Cache Metadata Example

```php
use Drupal\Core\Cache\Cache;

$build = [
  '#theme' => 'item_list',
  '#items' => $items,
  '#cache' => [
    'keys' => ['my_module', 'my_list', 'user', $uid],
    'contexts' => ['user.roles', 'url.path'],
    'tags' => ['node_list', 'config:my_module.settings'],
    'max-age' => 3600,
  ],
];
```

## Cache Keys

For render caching, use cache keys to identify unique variations:

```php
$build = [
  '#markup' => $content,
  '#cache' => [
    'keys' => ['my_module', 'my_component', $entity_id],
    'contexts' => ['user'],
    'tags' => ['node:' . $entity_id],
  ],
];
```

## Deletion vs. Invalidation

### Deletion

Permanently removes items from cache:

```php
// Delete single item
$cache->delete('my_id');

// Delete multiple items
$cache->deleteMultiple(['id1', 'id2']);

// Delete all items in bin
$cache->deleteAll();
```

### Invalidation

Marks items as stale (protects against cache stampedes):

```php
// Invalidate single item
$cache->invalidate('my_id');

// Invalidate multiple items
$cache->invalidateMultiple(['id1', 'id2']);

// Invalidate all items in bin
$cache->invalidateAll();
```

**Prefer invalidation** over deletion to prevent cache stampedes on high-traffic sites.

## Caching in Controllers

```php
public function myPage() {
  $content = $this->generateExpensiveContent();

  $build = [
    '#markup' => $content,
    '#cache' => [
      'contexts' => ['user.roles'],
      'tags' => ['node_list'],
      'max-age' => 3600,
    ],
  ];

  return $build;
}
```

## Caching in Blocks

```php
public function build() {
  return [
    '#markup' => $this->getBlockContent(),
    '#cache' => [
      'contexts' => ['user'],
      'tags' => ['config:block.block.' . $this->getPluginId()],
      'max-age' => Cache::PERMANENT,
    ],
  ];
}

public function getCacheContexts() {
  return ['user.roles'];
}

public function getCacheTags() {
  return ['node_list'];
}

public function getCacheMaxAge() {
  return 3600;
}
```

## Bubbling Cache Metadata

When building nested render arrays, cache metadata "bubbles up" from children to parents:

```php
$child = [
  '#markup' => 'Child content',
  '#cache' => [
    'tags' => ['node:1'],
    'max-age' => 3600,
  ],
];

$parent = [
  'child' => $child,
  '#cache' => [
    'tags' => ['node_list'],
    'max-age' => 7200,
  ],
];

// Parent automatically includes:
// - tags: ['node_list', 'node:1']
// - max-age: 3600 (lowest wins)
```

## Best Practices

1. **Always include cache metadata** in render arrays
2. **Use specific cache tags** for precise invalidation
3. **Choose appropriate contexts** to avoid over-caching
4. **Set reasonable max-age** values
5. **Prefer invalidation** over deletion
6. **Use permanent cache** when content rarely changes
7. **Use max-age 0** for user-specific or dynamic content
8. **Tag with entity IDs** for precise invalidation
9. **Tag with list types** (node_list, user_list) for bulk operations
10. **Consider cache contexts** carefully to balance performance vs. personalization
