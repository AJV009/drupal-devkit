# Form API

## Form Structure

### Basic Form

```php
namespace Drupal\my_module\Form;

use Drupal\Core\Form\FormBase;
use Drupal\Core\Form\FormStateInterface;

class MyForm extends FormBase {

  public function getFormId(): string {
    return 'my_module_my_form';
  }

  public function buildForm(array $form, FormStateInterface $form_state): array {
    $form['name'] = [
      '#type' => 'textfield',
      '#title' => $this->t('Name'),
      '#required' => TRUE,
      '#maxlength' => 255,
    ];

    $form['email'] = [
      '#type' => 'email',
      '#title' => $this->t('Email'),
      '#required' => TRUE,
    ];

    $form['age'] = [
      '#type' => 'number',
      '#title' => $this->t('Age'),
      '#min' => 18,
      '#max' => 120,
    ];

    $form['bio'] = [
      '#type' => 'textarea',
      '#title' => $this->t('Biography'),
      '#rows' => 5,
    ];

    $form['submit'] = [
      '#type' => 'submit',
      '#value' => $this->t('Submit'),
    ];

    return $form;
  }

  public function validateForm(array &$form, FormStateInterface $form_state): void {
    $email = $form_state->getValue('email');
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
      $form_state->setErrorByName('email', $this->t('Invalid email address.'));
    }
  }

  public function submitForm(array &$form, FormStateInterface $form_state): void {
    $values = $form_state->getValues();

    $this->messenger()->addMessage(
      $this->t('Thank you @name!', ['@name' => $values['name']])
    );

    // Redirect
    $form_state->setRedirect('my_module.success');
  }

}
```

## Configuration Form

For forms that save to configuration:

```php
namespace Drupal\my_module\Form;

use Drupal\Core\Form\ConfigFormBase;
use Drupal\Core\Form\FormStateInterface;

class SettingsForm extends ConfigFormBase {

  protected function getEditableConfigNames(): array {
    return ['my_module.settings'];
  }

  public function getFormId(): string {
    return 'my_module_settings_form';
  }

  public function buildForm(array $form, FormStateInterface $form_state): array {
    $config = $this->config('my_module.settings');

    $form['api_key'] = [
      '#type' => 'textfield',
      '#title' => $this->t('API Key'),
      '#default_value' => $config->get('api_key'),
      '#required' => TRUE,
    ];

    $form['enabled'] = [
      '#type' => 'checkbox',
      '#title' => $this->t('Enable feature'),
      '#default_value' => $config->get('enabled'),
    ];

    return parent::buildForm($form, $form_state);
  }

  public function submitForm(array &$form, FormStateInterface $form_state): void {
    $this->config('my_module.settings')
      ->set('api_key', $form_state->getValue('api_key'))
      ->set('enabled', $form_state->getValue('enabled'))
      ->save();

    parent::submitForm($form, $form_state);
  }

}
```

## Form Element Types

### Common Types

- `textfield` - Single-line text input
- `textarea` - Multi-line text input
- `email` - Email input with validation
- `number` - Numeric input
- `tel` - Telephone number
- `select` - Dropdown selection
- `checkboxes` - Multiple checkboxes
- `radios` - Radio buttons
- `checkbox` - Single checkbox
- `date` - Date picker
- `datetime` - Date and time picker
- `file` - File upload
- `managed_file` - Managed file upload (tracked in file_managed table)
- `password` - Password field
- `password_confirm` - Password with confirmation
- `hidden` - Hidden field
- `submit` - Submit button
- `button` - Generic button
- `item` - Display-only item
- `markup` - Raw markup
- `container` - Generic container
- `details` - Collapsible details
- `fieldset` - Fieldset

### Select Example

```php
$form['category'] = [
  '#type' => 'select',
  '#title' => $this->t('Category'),
  '#options' => [
    'news' => $this->t('News'),
    'blog' => $this->t('Blog'),
    'article' => $this->t('Article'),
  ],
  '#default_value' => 'news',
  '#required' => TRUE,
  '#empty_option' => $this->t('- Select -'),
];
```

### Checkboxes Example

```php
$form['features'] = [
  '#type' => 'checkboxes',
  '#title' => $this->t('Features'),
  '#options' => [
    'feature_a' => $this->t('Feature A'),
    'feature_b' => $this->t('Feature B'),
    'feature_c' => $this->t('Feature C'),
  ],
  '#default_value' => ['feature_a', 'feature_b'],
];
```

### Radios Example

```php
$form['status'] = [
  '#type' => 'radios',
  '#title' => $this->t('Status'),
  '#options' => [
    'active' => $this->t('Active'),
    'inactive' => $this->t('Inactive'),
  ],
  '#default_value' => 'active',
  '#required' => TRUE,
];
```

### Entity Reference Autocomplete

```php
$form['user'] = [
  '#type' => 'entity_autocomplete',
  '#title' => $this->t('User'),
  '#target_type' => 'user',
  '#selection_settings' => [
    'include_anonymous' => FALSE,
  ],
];
```

## AJAX in Forms

### Basic AJAX

```php
public function buildForm(array $form, FormStateInterface $form_state): array {
  $form['dropdown'] = [
    '#type' => 'select',
    '#title' => $this->t('Category'),
    '#options' => $this->getCategories(),
    '#ajax' => [
      'callback' => '::updateSubcategories',
      'wrapper' => 'subcategory-wrapper',
      'event' => 'change',
    ],
  ];

  $form['subcategory'] = [
    '#type' => 'select',
    '#title' => $this->t('Subcategory'),
    '#options' => $this->getSubcategories($form_state),
    '#prefix' => '<div id="subcategory-wrapper">',
    '#suffix' => '</div>',
  ];

  return $form;
}

public function updateSubcategories(array &$form, FormStateInterface $form_state): array {
  return $form['subcategory'];
}
```

### AJAX Commands

```php
use Drupal\Core\Ajax\AjaxResponse;
use Drupal\Core\Ajax\ReplaceCommand;
use Drupal\Core\Ajax\InvokeCommand;
use Drupal\Core\Ajax\AppendCommand;
use Drupal\Core\Ajax\PrependCommand;
use Drupal\Core\Ajax\HtmlCommand;

public function ajaxCallback(array &$form, FormStateInterface $form_state): AjaxResponse {
  $response = new AjaxResponse();

  // Replace element
  $response->addCommand(new ReplaceCommand('#element-id', $form['element']));

  // Update HTML
  $response->addCommand(new HtmlCommand('#target', '<p>New content</p>'));

  // Append content
  $response->addCommand(new AppendCommand('#target', '<p>Appended</p>'));

  // Prepend content
  $response->addCommand(new PrependCommand('#target', '<p>Prepended</p>'));

  // Invoke jQuery method
  $response->addCommand(new InvokeCommand('.my-class', 'addClass', ['highlight']));

  return $response;
}
```

## Form Validation

### Field-level Validation

```php
public function validateForm(array &$form, FormStateInterface $form_state): void {
  // Validate email
  $email = $form_state->getValue('email');
  if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $form_state->setErrorByName('email', $this->t('Invalid email address.'));
  }

  // Validate age
  $age = $form_state->getValue('age');
  if ($age < 18 || $age > 120) {
    $form_state->setErrorByName('age', $this->t('Age must be between 18 and 120.'));
  }

  // Validate URL
  $url = $form_state->getValue('url');
  if (!filter_var($url, FILTER_VALIDATE_URL)) {
    $form_state->setErrorByName('url', $this->t('Invalid URL.'));
  }
}
```

### Custom Element Validators

```php
$form['username'] = [
  '#type' => 'textfield',
  '#title' => $this->t('Username'),
  '#element_validate' => ['::validateUsername'],
];

public function validateUsername(array &$element, FormStateInterface $form_state, array &$complete_form): void {
  $value = $element['#value'];
  if (strlen($value) < 3) {
    $form_state->setError($element, $this->t('Username must be at least 3 characters.'));
  }
}
```

## Form State Operations

### Get Values

```php
// Get single value
$name = $form_state->getValue('name');

// Get nested value
$host = $form_state->getValue(['server', 'host']);

// Get all values
$values = $form_state->getValues();
```

### Set Values

```php
// Set single value
$form_state->setValue('name', 'John');

// Set nested value
$form_state->setValue(['server', 'host'], 'localhost');
```

### Storage

For multi-step forms, use storage:

```php
// Set storage
$form_state->set('step', 2);
$form_state->set('data', $data);

// Get storage
$step = $form_state->get('step');
$data = $form_state->get('data');
```

## Form Redirects

### Redirect to Route

```php
public function submitForm(array &$form, FormStateInterface $form_state): void {
  // Simple redirect
  $form_state->setRedirect('my_module.page');

  // With parameters
  $form_state->setRedirect('my_module.task.view', ['task' => $task_id]);

  // With query parameters
  $form_state->setRedirect('my_module.page', [], ['query' => ['page' => 2]]);
}
```

### Redirect to URL

```php
use Drupal\Core\Url;

$url = Url::fromRoute('my_module.page');
$form_state->setRedirectUrl($url);
```

## Dependency Injection in Forms

```php
namespace Drupal\my_module\Form;

use Drupal\Core\Form\FormBase;
use Drupal\Core\Form\FormStateInterface;
use Drupal\Core\Entity\EntityTypeManagerInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;

class MyForm extends FormBase {

  protected EntityTypeManagerInterface $entityTypeManager;

  public function __construct(EntityTypeManagerInterface $entity_type_manager) {
    $this->entityTypeManager = $entity_type_manager;
  }

  public static function create(ContainerInterface $container): static {
    return new static(
      $container->get('entity_type.manager')
    );
  }

  public function getFormId(): string {
    return 'my_module_my_form';
  }

  public function buildForm(array $form, FormStateInterface $form_state): array {
    // Use injected services
    $storage = $this->entityTypeManager->getStorage('node');

    // Build form...
    return $form;
  }

  // ...
}
```

## Multi-step Forms

```php
public function buildForm(array $form, FormStateInterface $form_state): array {
  $step = $form_state->get('step') ?? 1;

  if ($step === 1) {
    return $this->buildStepOne($form, $form_state);
  }
  else {
    return $this->buildStepTwo($form, $form_state);
  }
}

protected function buildStepOne(array $form, FormStateInterface $form_state): array {
  $form['name'] = [
    '#type' => 'textfield',
    '#title' => $this->t('Name'),
    '#required' => TRUE,
  ];

  $form['next'] = [
    '#type' => 'submit',
    '#value' => $this->t('Next'),
    '#submit' => ['::submitStepOne'],
  ];

  return $form;
}

protected function buildStepTwo(array $form, FormStateInterface $form_state): array {
  $form['email'] = [
    '#type' => 'email',
    '#title' => $this->t('Email'),
    '#required' => TRUE,
  ];

  $form['back'] = [
    '#type' => 'submit',
    '#value' => $this->t('Back'),
    '#submit' => ['::submitStepTwo'],
    '#limit_validation_errors' => [],
  ];

  $form['submit'] = [
    '#type' => 'submit',
    '#value' => $this->t('Submit'),
  ];

  return $form;
}

public function submitStepOne(array &$form, FormStateInterface $form_state): void {
  $form_state->set('step', 2);
  $form_state->set('name', $form_state->getValue('name'));
  $form_state->setRebuild(TRUE);
}

public function submitStepTwo(array &$form, FormStateInterface $form_state): void {
  $form_state->set('step', 1);
  $form_state->setRebuild(TRUE);
}

public function submitForm(array &$form, FormStateInterface $form_state): void {
  $name = $form_state->get('name');
  $email = $form_state->getValue('email');

  // Process final submission
  $this->messenger()->addMessage($this->t('Submitted: @name, @email', [
    '@name' => $name,
    '@email' => $email,
  ]));
}
```

## Best Practices

1. **Use type hints** on all methods
2. **Return types** on buildForm, validateForm, submitForm
3. **Use dependency injection** for services
4. **Validate user input** thoroughly
5. **Use translatable strings** with `$this->t()`
6. **Include CSRF protection** (automatic in Drupal forms)
7. **Escape output** (automatic in Form API)
8. **Use FormStateInterface methods** for state management
9. **Redirect after submission** to prevent double-submit
10. **Cache form metadata** when appropriate
