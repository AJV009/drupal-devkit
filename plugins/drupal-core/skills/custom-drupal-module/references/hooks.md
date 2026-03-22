# Hooks

In Drupal 11.1+, the preferred approach is PHP 8 `#[Hook]` attributes in a class — this supports full dependency injection and keeps hooks out of `.module` files. The old procedural function approach still works and is still required for `hook_theme()`, `hook_install()`, `hook_uninstall()`, `hook_schema()`, and `hook_update_N()`.

**Default rule**: Use `#[Hook]` attributes. Fall back to procedural only when required.

## #[Hook] Attribute Pattern (Default)

### Service registration

Create a hook class and register it as a tagged service:

**`src/Hook/MyModuleHooks.php`**

```php
<?php

namespace Drupal\my_module\Hook;

use Drupal\Core\Hook\Attribute\Hook;

class MyModuleHooks {
  // Hook methods go here (see examples below)
}
```

**`my_module.services.yml`**

```yaml
services:
  my_module.hooks:
    class: Drupal\my_module\Hook\MyModuleHooks
    tags:
      - { name: 'drupal.hook' }
```

Add constructor arguments for dependency injection as needed:

```yaml
services:
  my_module.hooks:
    class: Drupal\my_module\Hook\MyModuleHooks
    arguments:
      - '@logger.channel.my_module'
      - '@entity_type.manager'
    tags:
      - { name: 'drupal.hook' }
```

You can split hooks across multiple classes (e.g., `EntityHooks`, `FormHooks`) — each needs its own service tag entry.

---

## Common Hooks

### hook_help()

```php
use Drupal\Core\Hook\Attribute\Hook;
use Drupal\Core\Routing\RouteMatchInterface;

#[Hook('help')]
public function help(string $route_name, RouteMatchInterface $route_match): string {
  return match ($route_name) {
    'help.page.my_module' => '<h2>' . t('About') . '</h2><p>' . t('This module provides...') . '</p>',
    'my_module.settings' => '<p>' . t('Configure module settings here.') . '</p>',
    default => '',
  };
}
```

### hook_theme()

> **Must be procedural** — Drupal's theme registry runs before the service container. Place in `my_module.module`.

```php
function my_module_theme(array $existing, string $type, string $theme, string $path): array {
  return [
    'my_template' => [
      'variables' => [
        'items' => [],
        'title' => NULL,
      ],
      'template' => 'my-template',
    ],
  ];
}
```

### hook_preprocess_HOOK()

```php
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('preprocess_node')]
public function preprocessNode(array &$variables): void {
  $node = $variables['node'];
  $variables['custom_date'] = $this->dateFormatter
    ->format($node->getCreatedTime(), 'custom');
}

#[Hook('preprocess_page')]
public function preprocessPage(array &$variables): void {
  $variables['#attached']['library'][] = 'my_module/global';
}
```

### hook_form_alter()

```php
use Drupal\Core\Form\FormStateInterface;
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('form_alter')]
public function formAlter(array &$form, FormStateInterface $form_state, string $form_id): void {
  if ($form_id === 'node_article_form') {
    $form['title']['widget'][0]['value']['#description'] = t('Custom description');
    $form['actions']['submit']['#value'] = t('Save Article');
  }
}
```

### hook_form_FORM_ID_alter()

```php
use Drupal\Core\Form\FormStateInterface;
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('form_node_article_form_alter')]
public function formNodeArticleFormAlter(array &$form, FormStateInterface $form_state): void {
  $form['title']['widget'][0]['value']['#required'] = FALSE;
}
```

---

## Entity Hooks

### hook_entity_insert()

```php
use Drupal\Core\Entity\EntityInterface;
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('entity_insert')]
public function entityInsert(EntityInterface $entity): void {
  if ($entity->getEntityTypeId() === 'node') {
    $this->logger->notice('Node created: @title', ['@title' => $entity->label()]);
  }
}
```

### hook_entity_update()

```php
use Drupal\Core\Entity\EntityInterface;
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('entity_update')]
public function entityUpdate(EntityInterface $entity): void {
  if ($entity->getEntityTypeId() === 'node') {
    $original = $entity->original;
    if ($entity->label() !== $original->label()) {
      // Title changed
    }
  }
}
```

### hook_entity_delete()

```php
use Drupal\Core\Entity\EntityInterface;
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('entity_delete')]
public function entityDelete(EntityInterface $entity): void {
  if ($entity->getEntityTypeId() === 'node') {
    // Clean up related data
  }
}
```

### hook_entity_presave()

```php
use Drupal\Core\Entity\EntityInterface;
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('entity_presave')]
public function entityPresave(EntityInterface $entity): void {
  if ($entity->getEntityTypeId() === 'node' && $entity->bundle() === 'article') {
    $slug = strtolower(str_replace(' ', '-', $entity->getTitle()));
    $entity->set('field_slug', $slug);
  }
}
```

### hook_ENTITY_TYPE_insert() / _update() / _delete() / _presave()

For type-specific hooks, use the full hook name in the attribute:

```php
use Drupal\Core\Hook\Attribute\Hook;
use Drupal\node\NodeInterface;

#[Hook('node_insert')]
public function nodeInsert(NodeInterface $node): void {
  if ($node->bundle() === 'article') {
    // Handle article creation
  }
}

#[Hook('node_update')]
public function nodeUpdate(NodeInterface $node): void {
  // Handle node updates
}

#[Hook('node_presave')]
public function nodePresave(NodeInterface $node): void {
  // Modify node before saving
}
```

---

## Access Hooks

### hook_node_access()

```php
use Drupal\Core\Access\AccessResult;
use Drupal\Core\Hook\Attribute\Hook;
use Drupal\Core\Session\AccountInterface;
use Drupal\node\NodeInterface;

#[Hook('node_access')]
public function nodeAccess(NodeInterface $node, string $op, AccountInterface $account): AccessResult {
  if ($op === 'view' && $node->bundle() === 'private') {
    return AccessResult::forbiddenIf(!$account->hasPermission('view private content'))
      ->cachePerPermissions()
      ->addCacheableDependency($node);
  }
  return AccessResult::neutral();
}
```

### hook_entity_access()

```php
use Drupal\Core\Access\AccessResult;
use Drupal\Core\Entity\EntityInterface;
use Drupal\Core\Hook\Attribute\Hook;
use Drupal\Core\Session\AccountInterface;

#[Hook('entity_access')]
public function entityAccess(EntityInterface $entity, string $operation, AccountInterface $account): AccessResult {
  if ($entity->getEntityTypeId() === 'my_entity' && $operation === 'update') {
    if ($entity->getOwnerId() !== $account->id()) {
      return AccessResult::forbidden()->cachePerUser();
    }
  }
  return AccessResult::neutral();
}
```

### hook_entity_create_access()

```php
use Drupal\Core\Access\AccessResult;
use Drupal\Core\Hook\Attribute\Hook;
use Drupal\Core\Session\AccountInterface;

#[Hook('entity_create_access')]
public function entityCreateAccess(AccountInterface $account, array $context, ?string $entity_bundle): AccessResult {
  if ($context['entity_type_id'] === 'node' && $entity_bundle === 'article') {
    return AccessResult::allowedIf($account->hasPermission('create article'))
      ->cachePerPermissions();
  }
  return AccessResult::neutral();
}
```

---

## Views Hooks

### hook_views_data()

```php
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('views_data')]
public function viewsData(): array {
  $data = [];
  $data['my_table']['table']['group'] = t('My Module');
  $data['my_table']['table']['base'] = [
    'field' => 'id',
    'title' => t('My Table'),
    'help' => t('Custom table for Views'),
  ];
  $data['my_table']['id'] = [
    'title' => t('ID'),
    'field' => ['id' => 'numeric'],
    'sort' => ['id' => 'standard'],
    'filter' => ['id' => 'numeric'],
  ];
  return $data;
}
```

### hook_views_data_alter()

```php
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('views_data_alter')]
public function viewsDataAlter(array &$data): void {
  $data['node_field_data']['custom_field'] = [
    'title' => t('Custom Field'),
    'field' => ['id' => 'custom_field_handler'],
  ];
}
```

---

## Page and Render Hooks

### hook_page_attachments()

```php
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('page_attachments')]
public function pageAttachments(array &$attachments): void {
  $attachments['#attached']['library'][] = 'my_module/global';
  $attachments['#attached']['drupalSettings']['myModule'] = [
    'apiUrl' => 'https://api.example.com',
  ];
}
```

### hook_page_attachments_alter()

```php
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('page_attachments_alter')]
public function pageAttachmentsAlter(array &$attachments): void {
  if (isset($attachments['#attached']['library'])) {
    $key = array_search('some_module/library', $attachments['#attached']['library']);
    if ($key !== FALSE) {
      unset($attachments['#attached']['library'][$key]);
    }
  }
}
```

---

## Module Hooks (Must be procedural — run before container)

`hook_install()`, `hook_uninstall()`, `hook_schema()`, and `hook_update_N()` **must** remain in `.install` and `.module` files.

### hook_install()

```php
// my_module.install
function my_module_install(): void {
  \Drupal::configFactory()->getEditable('my_module.settings')
    ->set('api_key', '')
    ->set('enabled', TRUE)
    ->save();
}
```

### hook_uninstall()

```php
// my_module.install
function my_module_uninstall(): void {
  \Drupal::configFactory()->getEditable('my_module.settings')->delete();
  \Drupal::database()->schema()->dropTable('my_custom_table');
}
```

### hook_schema()

```php
// my_module.install
function my_module_schema(): array {
  $schema['my_table'] = [
    'description' => 'Stores custom data',
    'fields' => [
      'id' => ['type' => 'serial', 'not null' => TRUE],
      'name' => ['type' => 'varchar', 'length' => 255, 'not null' => TRUE],
      'created' => ['type' => 'int', 'not null' => TRUE],
    ],
    'primary key' => ['id'],
    'indexes' => ['name' => ['name']],
  ];
  return $schema;
}
```

### hook_update_N()

```php
// my_module.install
function my_module_update_9001(): string {
  $schema = \Drupal::database()->schema();
  $schema->addField('my_table', 'status', [
    'type' => 'varchar',
    'length' => 20,
    'not null' => TRUE,
    'default' => 'active',
  ]);
  return t('Added status field to my_table.');
}
```

---

## Token Hooks

### hook_token_info()

```php
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('token_info')]
public function tokenInfo(): array {
  return [
    'types' => [
      'custom' => ['name' => t('Custom tokens'), 'description' => t('Tokens for custom data')],
    ],
    'tokens' => [
      'custom' => [
        'greeting' => ['name' => t('Greeting'), 'description' => t('A custom greeting')],
      ],
    ],
  ];
}
```

### hook_tokens()

```php
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('tokens')]
public function tokens(string $type, array $tokens, array $data, array $options): array {
  $replacements = [];
  if ($type === 'custom') {
    foreach ($tokens as $name => $original) {
      if ($name === 'greeting') {
        $replacements[$original] = t('Hello, World!');
      }
    }
  }
  return $replacements;
}
```

---

## Best Practices

1. **Always use `#[Hook]` attributes** — keeps hooks in classes with DI, not `.module` files
2. **Use procedural only when required**: `hook_theme()`, `hook_install()`, `hook_uninstall()`, `hook_schema()`, `hook_update_N()`
3. **Split hooks into focused classes**: `EntityHooks`, `FormHooks`, `AccessHooks` — one class per concern
4. **Use typed entity hooks** (`hook_node_insert` vs `hook_entity_insert`) for better performance
5. **Return proper access results** with cache metadata in access hooks
6. **Test hook implementations** — kernel tests for entity hooks, functional tests for form hooks

## When to Use Hooks vs Events

**Use Hooks (`#[Hook]`) when:**
- Altering forms (`hook_form_alter`)
- Entity CRUD reactions (`hook_entity_insert`, `hook_node_update`, etc.)
- Theme preprocessing (`hook_preprocess_*`)
- Token system, Views data, page attachments
- Module install/uninstall/update (procedural, `.install` file)

**Use Event Subscribers when:**
- Request/response cycle (Symfony kernel events)
- Routing events (`RoutingEvents::ALTER`)
- Custom dispatched events (your own or contrib)
- Config events

**Do NOT use `hook_event_dispatcher` contrib** for new code in Drupal 11.3+ — hooks no longer run through the event dispatcher internally.
