# Render API & Theming

## Render Arrays

The fundamental structure in Drupal's theme system. Structured hierarchical arrays containing data for rendering.

### Basic Render Array

```php
$build = [
  '#type' => 'markup',
  '#markup' => '<p>Hello World</p>',
  '#cache' => [
    'max-age' => 3600,
  ],
];
```

### Complex Render Array

```php
$build = [
  '#theme' => 'item_list',
  '#items' => $items,
  '#title' => $this->t('My List'),
  '#list_type' => 'ul',
  '#attributes' => [
    'class' => ['my-custom-class'],
  ],
  '#cache' => [
    'contexts' => ['user.roles'],
    'tags' => ['node_list'],
    'max-age' => 3600,
  ],
  '#attached' => [
    'library' => ['my_module/my_library'],
    'drupalSettings' => [
      'myModule' => ['key' => 'value'],
    ],
  ],
];
```

## Render Element Types

### Common Types

- `markup` - Raw HTML
- `html_tag` - Single HTML element
- `link` - Themed link
- `table` - Themed table
- `item_list` - Themed list
- `details` - Collapsible details
- `container` - Generic container
- `inline_template` - Inline Twig template
- `processed_text` - Formatted text with text format
- `view` - Embedded view
- `more_link` - "More" link

### Examples

```php
// Container
$build['content'] = [
  '#type' => 'container',
  '#attributes' => ['class' => ['wrapper']],
];

// HTML tag
$build['content']['title'] = [
  '#type' => 'html_tag',
  '#tag' => 'h2',
  '#value' => $this->t('Title'),
  '#attributes' => ['class' => ['title']],
];

// Link
$build['content']['link'] = [
  '#type' => 'link',
  '#title' => $this->t('Read more'),
  '#url' => Url::fromRoute('my_module.page'),
  '#attributes' => ['class' => ['button']],
];

// Table
$build['table'] = [
  '#type' => 'table',
  '#header' => [$this->t('Name'), $this->t('Email')],
  '#rows' => $rows,
  '#empty' => $this->t('No data available'),
];

// Details
$build['details'] = [
  '#type' => 'details',
  '#title' => $this->t('Advanced settings'),
  '#open' => FALSE,
];

// Inline template
$build['custom'] = [
  '#type' => 'inline_template',
  '#template' => '<div class="custom">{{ content }}</div>',
  '#context' => [
    'content' => $content,
  ],
];
```

## Theme Hooks

### Define Theme Hook

In `my_module.module`:

```php
function my_module_theme($existing, $type, $theme, $path) {
  return [
    'my_custom_template' => [
      'variables' => [
        'title' => NULL,
        'items' => [],
        'show_footer' => TRUE,
      ],
      'template' => 'my-custom-template',
    ],
  ];
}
```

### Template File

`templates/my-custom-template.html.twig`:

```twig
<div class="my-custom">
  <h2>{{ title }}</h2>
  <ul>
    {% for item in items %}
      <li>{{ item }}</li>
    {% endfor %}
  </ul>
  {% if show_footer %}
    <footer>Footer content</footer>
  {% endif %}
</div>
```

### Use in Code

```php
$build = [
  '#theme' => 'my_custom_template',
  '#title' => $this->t('My Title'),
  '#items' => ['Item 1', 'Item 2', 'Item 3'],
  '#show_footer' => TRUE,
];
```

## Preprocess Functions

Use `#[Hook]` attributes in a tagged service class (see `hooks.md`). Inject services via the constructor — no `\Drupal::service()` needed.

### Preprocess Node

```php
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('preprocess_node')]
public function preprocessNode(array &$variables): void {
  $node = $variables['node'];

  // Add custom variable (injected service via constructor)
  $variables['custom_date'] = $this->dateFormatter
    ->format($node->getCreatedTime(), 'custom');

  // Modify existing variable
  $variables['attributes']['class'][] = 'custom-class';

  // Add conditional class
  if ($node->isPromoted()) {
    $variables['attributes']['class'][] = 'promoted';
  }
}
```

### Preprocess Block

```php
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('preprocess_block')]
public function preprocessBlock(array &$variables): void {
  $variables['attributes']['class'][] = 'block-' . $variables['elements']['#id'];
  $variables['custom_data'] = 'value';
}
```

### Preprocess Page

```php
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('preprocess_page')]
public function preprocessPage(array &$variables): void {
  $variables['#attached']['library'][] = 'my_module/global';

  if ($this->routeMatch->getRouteName() === 'my_module.page') {
    $variables['custom_page'] = TRUE;
  }
}
```

### Preprocess Custom Template

```php
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('preprocess_my_custom_template')]
public function preprocessMyCustomTemplate(array &$variables): void {
  $variables['processed_items'] = array_map(
    fn($item) => strtoupper($item),
    $variables['items']
  );
}
```

## Theme Suggestions

### Add Suggestions in Preprocess

```php
use Drupal\Core\Hook\Attribute\Hook;

#[Hook('preprocess_node')]
public function preprocessNodeSuggestions(array &$variables): void {
  $node = $variables['node'];

  // node--article.html.twig
  $variables['theme_hook_suggestions'][] = 'node__' . $node->bundle();

  // node--article--123.html.twig
  $variables['theme_hook_suggestions'][] = 'node__' . $node->bundle() . '__' . $node->id();

  // node--article--full.html.twig
  $variables['theme_hook_suggestions'][] = 'node__' . $node->bundle() . '__' . $variables['view_mode'];
}
```

### Hook for Suggestions

```php
function my_module_theme_suggestions_node_alter(array &$suggestions, array $variables) {
  $node = $variables['elements']['#node'];

  if ($node->bundle() === 'article' && $node->isPromoted()) {
    $suggestions[] = 'node__article__promoted';
  }
}
```

## Asset Libraries

### Define Libraries

`my_module.libraries.yml`:

```yaml
global:
  css:
    theme:
      css/style.css: {}
      css/print.css: { media: print }
  js:
    js/script.js: {}
  dependencies:
    - core/drupal
    - core/jquery

my-library:
  css:
    component:
      css/component.css: {}
  js:
    js/component.js: {}
    https://cdn.example.com/external.js: { type: external, minified: true }
  dependencies:
    - my_module/global
```

### Attach Libraries

#### In Render Array

```php
$build['#attached']['library'][] = 'my_module/my-library';
```

#### In Preprocess

```php
function my_module_preprocess_page(&$variables) {
  $variables['#attached']['library'][] = 'my_module/global';
}
```

#### Conditionally

```php
function my_module_preprocess_node(&$variables) {
  $node = $variables['node'];

  if ($node->bundle() === 'article') {
    $variables['#attached']['library'][] = 'my_module/article';
  }
}
```

## Twig Templates

### Variables

```twig
{# Output with auto-escaping #}
{{ title }}

{# Raw output (trusted content only) #}
{{ content|raw }}

{# Translation #}
{{ 'Hello @name'|t({'@name': name}) }}

{# URL generation #}
<a href="{{ path('my_module.page') }}">Link</a>
<a href="{{ url('my_module.page', {'id': node.id}) }}">Link with param</a>
```

### Conditionals

```twig
{% if items %}
  <ul>
    {% for item in items %}
      <li>{{ item }}</li>
    {% endfor %}
  </ul>
{% else %}
  <p>{{ 'No items found'|t }}</p>
{% endif %}

{% if node.bundle == 'article' %}
  {# Article-specific content #}
{% endif %}
```

### Loops

```twig
{% for item in items %}
  <div class="item {{ loop.index }}">
    {{ item }}
  </div>
{% endfor %}

{# Loop variables #}
{{ loop.index }}      {# 1-indexed #}
{{ loop.index0 }}     {# 0-indexed #}
{{ loop.first }}      {# TRUE on first iteration #}
{{ loop.last }}       {# TRUE on last iteration #}
{{ loop.length }}     {# Total iterations #}
```

### Filters

```twig
{{ text|upper }}
{{ text|lower }}
{{ text|capitalize }}
{{ text|length }}
{{ date|date('Y-m-d') }}
{{ url|escape }}
{{ content|striptags }}
{{ number|number_format(2, '.', ',') }}

{# Drupal-specific filters #}
{{ 'Hello @name'|t({'@name': name}) }}
{{ text|placeholder }}
{{ text|drupal_escape }}
```

### Set Variables

```twig
{% set custom_var = 'value' %}
{% set count = items|length %}
{% set classes = [
  'item',
  'item--' ~ type,
  promoted ? 'promoted'
] %}
```

### Include

```twig
{% include 'my-module/partials/header.html.twig' %}

{% include 'my-module/partials/item.html.twig' with {
  'title': item.title,
  'content': item.content
} %}
```

### Extend and Block

Base template `templates/base.html.twig`:

```twig
<!DOCTYPE html>
<html>
<head>
  <title>{% block title %}Default Title{% endblock %}</title>
</head>
<body>
  {% block content %}{% endblock %}
</body>
</html>
```

Child template:

```twig
{% extends 'my-module/base.html.twig' %}

{% block title %}Custom Title{% endblock %}

{% block content %}
  <h1>{{ title }}</h1>
  {{ content }}
{% endblock %}
```

## Attributes in Twig

### Working with Attributes

```twig
{# Add class #}
{% set attributes = attributes.addClass('my-class') %}

{# Add multiple classes #}
{% set attributes = attributes.addClass(['class1', 'class2']) %}

{# Remove class #}
{% set attributes = attributes.removeClass('old-class') %}

{# Set attribute #}
{% set attributes = attributes.setAttribute('data-id', id) %}

{# Remove attribute #}
{% set attributes = attributes.removeAttribute('data-old') %}

{# Check if attribute exists #}
{% if attributes.hasClass('my-class') %}
  {# ... #}
{% endif %}

{# Print all attributes #}
<div{{ attributes }}>Content</div>
```

### Title Attributes

```twig
<div{{ attributes }}>
  <h2{{ title_attributes }}>{{ title }}</h2>
  <div{{ content_attributes }}>{{ content }}</div>
</div>
```

## drupalSettings

### Attach Settings in PHP

```php
$build['#attached']['drupalSettings']['myModule'] = [
  'apiUrl' => 'https://api.example.com',
  'userId' => $user->id(),
  'settings' => $config->get('settings'),
];
```

### Access in JavaScript

```javascript
(function (Drupal, drupalSettings) {
  Drupal.behaviors.myModule = {
    attach: function (context, settings) {
      const apiUrl = drupalSettings.myModule.apiUrl;
      const userId = drupalSettings.myModule.userId;

      // Use settings
    }
  };
})(Drupal, drupalSettings);
```

## Best Practices

1. **Always include cache metadata** in render arrays
2. **Use theme hooks** for reusable templates
3. **Add preprocess functions** for data transformation
4. **Use theme suggestions** for template variations
5. **Attach libraries** only when needed
6. **Use Twig filters** for output manipulation
7. **Leverage attributes objects** for flexible markup
8. **Include accessibility attributes** (aria-*, role)
9. **Use translatable strings** in templates
10. **Keep templates simple** - logic in preprocess, not templates
