# Plugin API

## Core Concept

The Plugin API enables modules to provide extensible, object-oriented functionality. A controlling module defines an interface, while other modules implement plugins with specific behaviors.

## Plugin Types in Core

- **Block system**: Block types
- **Entity/Field system**: Entity types, field types, formatters, widgets
- **Image manipulation**: Image effects and toolkits
- **Search system**: Search page types
- **Queue**: Queue workers
- **Condition**: Condition plugins for visibility and access

## Discovery Mechanisms

### 1. Annotation/Attribute (Most Common)

Use PHP 8 attributes for plugin discovery:

```php
namespace Drupal\my_module\Plugin\Block;

use Drupal\Core\Block\BlockBase;
use Drupal\Core\Block\Attribute\Block;
use Drupal\Core\StringTranslation\TranslatableMarkup;

#[Block(
  id: 'my_custom_block',
  admin_label: new TranslatableMarkup('My Custom Block'),
  category: new TranslatableMarkup('Custom')
)]
class MyCustomBlock extends BlockBase {

  public function build() {
    return [
      '#markup' => $this->t('Custom block content'),
      '#cache' => [
        'contexts' => ['user'],
        'tags' => ['node_list'],
        'max-age' => 3600,
      ],
    ];
  }

}
```

### 2. YAML Discovery

Useful when all plugins share one class:

```yaml
# my_module.custom_plugins.yml
my_plugin_id:
  label: 'My Plugin'
  description: 'Plugin description'
  class: 'Drupal\my_module\Plugin\CustomPlugin'
```

### 3. Hook-based

Legacy approach, still supported:

```php
function my_module_custom_plugin_info() {
  return [
    'my_plugin' => [
      'label' => t('My Plugin'),
      'class' => 'Drupal\my_module\Plugin\CustomPlugin',
    ],
  ];
}
```

## Plugin Derivatives

Enable a single class to present as multiple plugins:

```php
namespace Drupal\my_module\Plugin\Derivative;

use Drupal\Component\Plugin\Derivative\DeriverBase;

class MenuBlockDeriver extends DeriverBase {

  public function getDerivativeDefinitions($base_plugin_definition) {
    $menus = \Drupal::entityTypeManager()->getStorage('menu')->loadMultiple();

    foreach ($menus as $menu_id => $menu) {
      $this->derivatives[$menu_id] = $base_plugin_definition;
      $this->derivatives[$menu_id]['admin_label'] = t('Menu: @label', ['@label' => $menu->label()]);
    }

    return $this->derivatives;
  }

}
```

Reference the deriver in your plugin:

```php
#[Block(
  id: 'menu_block',
  admin_label: new TranslatableMarkup('Menu Block'),
  deriver: 'Drupal\my_module\Plugin\Derivative\MenuBlockDeriver'
)]
```

## Using Plugins

### Get Plugin Manager

```php
// Get plugin manager
$block_manager = \Drupal::service('plugin.manager.block');

// Get definitions
$definitions = $block_manager->getDefinitions();

// Create instance
$config = ['label' => 'My Block'];
$block = $block_manager->createInstance('my_custom_block', $config);

// Use plugin
$build = $block->build();
```

### With Dependency Injection

```php
use Drupal\Core\Block\BlockManagerInterface;

public function __construct(BlockManagerInterface $block_manager) {
  $this->blockManager = $block_manager;
}

public static function create(ContainerInterface $container) {
  return new static(
    $container->get('plugin.manager.block')
  );
}
```

## Common Plugin Types

### Block Plugins

```php
namespace Drupal\my_module\Plugin\Block;

use Drupal\Core\Block\BlockBase;
use Drupal\Core\Block\Attribute\Block;
use Drupal\Core\Form\FormStateInterface;

#[Block(
  id: 'configurable_block',
  admin_label: new TranslatableMarkup('Configurable Block'),
  category: new TranslatableMarkup('Custom')
)]
class ConfigurableBlock extends BlockBase {

  public function defaultConfiguration() {
    return [
      'items_per_page' => 10,
      'show_title' => TRUE,
    ];
  }

  public function blockForm($form, FormStateInterface $form_state) {
    $form['items_per_page'] = [
      '#type' => 'number',
      '#title' => $this->t('Items per page'),
      '#default_value' => $this->configuration['items_per_page'],
      '#min' => 1,
      '#max' => 50,
    ];

    $form['show_title'] = [
      '#type' => 'checkbox',
      '#title' => $this->t('Show title'),
      '#default_value' => $this->configuration['show_title'],
    ];

    return $form;
  }

  public function blockSubmit($form, FormStateInterface $form_state) {
    $this->configuration['items_per_page'] = $form_state->getValue('items_per_page');
    $this->configuration['show_title'] = $form_state->getValue('show_title');
  }

  public function build() {
    $items_per_page = $this->configuration['items_per_page'];
    $show_title = $this->configuration['show_title'];

    return [
      '#markup' => $this->t('Configured block with @count items', [
        '@count' => $items_per_page,
      ]),
      '#cache' => [
        'contexts' => ['user'],
        'tags' => ['config:block.block.configurable_block'],
      ],
    ];
  }

}
```

### Field Formatter Plugins

```php
namespace Drupal\my_module\Plugin\Field\FieldFormatter;

use Drupal\Core\Field\FieldItemListInterface;
use Drupal\Core\Field\FormatterBase;
use Drupal\Core\Field\Attribute\FieldFormatter;

#[FieldFormatter(
  id: 'my_custom_formatter',
  label: new TranslatableMarkup('Custom Formatter'),
  field_types: ['string', 'text']
)]
class MyCustomFormatter extends FormatterBase {

  public function viewElements(FieldItemListInterface $items, $langcode) {
    $elements = [];

    foreach ($items as $delta => $item) {
      $elements[$delta] = [
        '#markup' => strtoupper($item->value),
      ];
    }

    return $elements;
  }

}
```

### Field Widget Plugins

```php
namespace Drupal\my_module\Plugin\Field\FieldWidget;

use Drupal\Core\Field\FieldItemListInterface;
use Drupal\Core\Field\WidgetBase;
use Drupal\Core\Form\FormStateInterface;
use Drupal\Core\Field\Attribute\FieldWidget;

#[FieldWidget(
  id: 'my_custom_widget',
  label: new TranslatableMarkup('Custom Widget'),
  field_types: ['string']
)]
class MyCustomWidget extends WidgetBase {

  public function formElement(FieldItemListInterface $items, $delta, array $element, array &$form, FormStateInterface $form_state) {
    $element['value'] = $element + [
      '#type' => 'textfield',
      '#default_value' => $items[$delta]->value ?? '',
      '#placeholder' => $this->t('Enter value'),
      '#maxlength' => 255,
    ];

    return $element;
  }

}
```

## Plugin Manager Services

Common plugin manager services:

- `plugin.manager.block` - Block plugins
- `plugin.manager.field.formatter` - Field formatters
- `plugin.manager.field.widget` - Field widgets
- `plugin.manager.field.field_type` - Field types
- `plugin.manager.condition` - Condition plugins
- `plugin.manager.queue_worker` - Queue workers
- `plugin.manager.image.effect` - Image effects

## Best Practices

1. **Use PHP 8 attributes** not annotations
2. **Implement dependency injection** in plugins when needed
3. **Include cache metadata** in build() methods
4. **Use TranslatableMarkup** for user-facing strings
5. **Provide configuration forms** when plugins are configurable
6. **Use derivatives** for dynamic plugin variations
7. **Document plugin properties** clearly
