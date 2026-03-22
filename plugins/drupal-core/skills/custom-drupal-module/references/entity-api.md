# Entity API

## Core Concepts

Entities are objects used for persistent storage of content and configuration information. The Entity API is foundational to Drupal's data management.

Use doc type hinting.
❌ DON'T DO:
```php
$foo = $node->get('some_entity_reference')->entity;
assert($foo instanceof \Drupal\taxonomy_term\TermInterface);
```
✅ DO:
```php
/** @var \Drupal\taxonomy_term\TermInterface $foo */
$foo = $node->get('some_entity_reference')->entity;

// Put your code in an if statement
$foo = $node->get('some_entity_reference')->entity;
if ($foo instanceof \Drupal\taxonomy_term\TermInterface) {

}
```

## Entity Types and Bundles

**Entity Types**: Different kinds of persistent objects (node, user, taxonomy_term, custom entities)

**Bundles**: Sub-types of entity types (e.g., Node has bundles called "content types" like article, page)

Some entity types have only one bundle (e.g., User), while others support multiple bundles.

## Defining Content Entities

### 1. Create Interface

```php
namespace Drupal\my_module\Entity;

use Drupal\Core\Entity\ContentEntityInterface;

interface TaskInterface extends ContentEntityInterface {
  public function getTitle(): string;
  public function setTitle(string $title): self;
  public function getStatus(): string;
}
```

### 2. Create Entity Class

```php
namespace Drupal\my_module\Entity;

use Drupal\Core\Entity\ContentEntityBase;
use Drupal\Core\Entity\EntityTypeInterface;
use Drupal\Core\Field\BaseFieldDefinition;
use Drupal\Core\Entity\Attribute\ContentEntityType;
use Drupal\Core\StringTranslation\TranslatableMarkup;

#[ContentEntityType(
  id: 'task',
  label: new TranslatableMarkup('Task'),
  label_collection: new TranslatableMarkup('Tasks'),
  label_singular: new TranslatableMarkup('task'),
  label_plural: new TranslatableMarkup('tasks'),
  label_count: [
    'singular' => '@count task',
    'plural' => '@count tasks',
  ],
  handlers: [
    'view_builder' => 'Drupal\Core\Entity\EntityViewBuilder',
    'list_builder' => 'Drupal\my_module\TaskListBuilder',
    'views_data' => 'Drupal\views\EntityViewsData',
    'form' => [
      'add' => 'Drupal\my_module\Form\TaskForm',
      'edit' => 'Drupal\my_module\Form\TaskForm',
      'delete' => 'Drupal\Core\Entity\ContentEntityDeleteForm',
    ],
    'route_provider' => [
      'html' => 'Drupal\Core\Entity\Routing\AdminHtmlRouteProvider',
    ],
    'access' => 'Drupal\my_module\TaskAccessControlHandler',
  ],
  base_table: 'task',
  data_table: 'task_field_data',
  translatable: TRUE,
  admin_permission: 'administer task entities',
  entity_keys: [
    'id' => 'id',
    'uuid' => 'uuid',
    'label' => 'title',
    'langcode' => 'langcode',
  ],
  links: [
    'canonical' => '/task/{task}',
    'add-form' => '/task/add',
    'edit-form' => '/task/{task}/edit',
    'delete-form' => '/task/{task}/delete',
    'collection' => '/admin/content/task',
  ]
)]
class Task extends ContentEntityBase implements TaskInterface {

  public function getTitle(): string {
    return $this->get('title')->value;
  }

  public function setTitle(string $title): self {
    $this->set('title', $title);
    return $this;
  }

  public static function baseFieldDefinitions(EntityTypeInterface $entity_type) {
    $fields = parent::baseFieldDefinitions($entity_type);

    $fields['title'] = BaseFieldDefinition::create('string')
      ->setLabel(new TranslatableMarkup('Title'))
      ->setRequired(TRUE)
      ->setTranslatable(TRUE)
      ->setSetting('max_length', 255)
      ->setDisplayOptions('view', [
        'label' => 'hidden',
        'type' => 'string',
        'weight' => -5,
      ])
      ->setDisplayOptions('form', [
        'type' => 'string_textfield',
        'weight' => -5,
      ])
      ->setDisplayConfigurable('form', TRUE)
      ->setDisplayConfigurable('view', TRUE);

    $fields['status'] = BaseFieldDefinition::create('list_string')
      ->setLabel(new TranslatableMarkup('Status'))
      ->setRequired(TRUE)
      ->setSetting('allowed_values', [
        'todo' => 'To Do',
        'in_progress' => 'In Progress',
        'done' => 'Done',
      ])
      ->setDefaultValue('todo')
      ->setDisplayOptions('view', [
        'label' => 'inline',
        'type' => 'list_default',
        'weight' => 0,
      ])
      ->setDisplayOptions('form', [
        'type' => 'options_select',
        'weight' => 0,
      ])
      ->setDisplayConfigurable('form', TRUE)
      ->setDisplayConfigurable('view', TRUE);

    return $fields;
  }

}
```

## Configuration Entities

For site configuration (not user-generated content):

```php
use Drupal\Core\Config\Entity\ConfigEntityBase;
use Drupal\Core\Entity\Attribute\ConfigEntityType;

#[ConfigEntityType(
  id: 'robot',
  label: new TranslatableMarkup('Robot'),
  handlers: [
    'list_builder' => 'Drupal\my_module\RobotListBuilder',
    'form' => [
      'add' => 'Drupal\my_module\Form\RobotForm',
      'edit' => 'Drupal\my_module\Form\RobotForm',
      'delete' => 'Drupal\Core\Entity\EntityDeleteForm',
    ],
  ],
  config_prefix: 'robot',
  admin_permission: 'administer robots',
  entity_keys: [
    'id' => 'id',
    'label' => 'label',
  ],
  config_export: [
    'id',
    'label',
    'model',
  ],
  links: [
    'collection' => '/admin/structure/robot',
    'add-form' => '/admin/structure/robot/add',
    'edit-form' => '/admin/structure/robot/{robot}',
    'delete-form' => '/admin/structure/robot/{robot}/delete',
  ]
)]
class Robot extends ConfigEntityBase {
  // Implementation
}
```

## Loading and Querying Entities

### Load Single Entity

```php
$storage = $this->entityTypeManager->getStorage('node');
$node = $storage->load($nid);
```

### Entity Query

```php
$query = $this->entityTypeManager->getStorage('node')->getQuery()
  ->accessCheck(TRUE)
  ->condition('type', 'article')
  ->condition('status', 1)
  ->range(0, 10)
  ->sort('created', 'DESC');
$nids = $query->execute();
$nodes = $storage->loadMultiple($nids);
```

**CRITICAL**: Always use `->accessCheck(TRUE)` or `->accessCheck(FALSE)` immediately after `getQuery()` to avoid deprecation warnings.

**When to use TRUE vs FALSE**:
- `->accessCheck(TRUE)` - When query results should respect user permissions (user-facing queries)
- `->accessCheck(FALSE)` - When query is administrative or system-level (migrations, batch, admin tools)

## Rendering Entities

```php
$view_builder = $this->entityTypeManager->getViewBuilder('node');
$build = $view_builder->view($node, 'teaser');
```

## Access Control

```php
// Check access
if ($entity->access('update')) {
  // User can edit
}

// Check with specific account
if ($entity->access('delete', $account)) {
  // Account can delete
}
```

**Access Results**: `allowed`, `forbidden`, or `neutral`

## Field Types for Base Fields

Common field types for `BaseFieldDefinition::create()`:

- `string` - Single-line text
- `string_long` - Multi-line text
- `text` - Formatted text with text format
- `integer` - Integer number
- `decimal` - Decimal number
- `float` - Float number
- `boolean` - Boolean (checkbox)
- `email` - Email address
- `uri` - URI/URL
- `timestamp` - Unix timestamp
- `created` - Creation timestamp
- `changed` - Last modified timestamp
- `list_string` - List with allowed values
- `list_integer` - Integer list with allowed values
- `entity_reference` - Reference to another entity
- `file` - File upload
- `image` - Image upload
- `date` - Date only
- `datetime` - Date and time

## Entity Reference Fields

```php
$fields['user_id'] = BaseFieldDefinition::create('entity_reference')
  ->setLabel(new TranslatableMarkup('Owner'))
  ->setSetting('target_type', 'user')
  ->setSetting('handler', 'default')
  ->setDisplayOptions('view', [
    'label' => 'above',
    'type' => 'entity_reference_label',
    'weight' => 0,
  ])
  ->setDisplayOptions('form', [
    'type' => 'entity_reference_autocomplete',
    'weight' => 0,
    'settings' => [
      'match_operator' => 'CONTAINS',
      'size' => 60,
      'placeholder' => '',
    ],
  ])
  ->setDisplayConfigurable('form', TRUE)
  ->setDisplayConfigurable('view', TRUE);
```

## Best Practices

1. **Always implement an interface** for your entity
2. **Use PHP 8 attributes** not annotations
3. **Include proper cache metadata** in handlers
4. **Use `accessCheck()` in all entity queries**
5. **Make fields translatable** where appropriate
6. **Set display options** for form and view modes
7. **Make displays configurable** with `setDisplayConfigurable()`
8. **Use TranslatableMarkup** for all user-facing strings
