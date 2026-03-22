# Security Best Practices

## Twig Auto-Escaping — The Default and Preferred Output Method

**All `{{ variable }}` output in Twig is automatically HTML-escaped.** This is the primary defence against XSS in Drupal. Prefer Twig templates over PHP output wherever possible.

```twig
{# These are ALL safe — auto-escaped automatically #}
{{ user_input }}
{{ title }}
{{ content }}

{# DANGEROUS — only use |raw for content you fully trust/have already sanitised #}
{{ trusted_html_content|raw }}
```

**Never use `|raw` on user-supplied content.** If you must render HTML from user input, filter it first with `Xss::filter()` in PHP, then pass the result as a render array with `#markup`.

## Output Escaping

### In PHP

Always escape untrusted data before output:

```php
use Drupal\Component\Utility\Html;
use Drupal\Component\Utility\Xss;
use Drupal\Component\Utility\UrlHelper;

// Escape HTML — strips ALL tags, encodes entities
$safe = Html::escape($user_input);

// Filter limited HTML — allows a safe subset of tags:
// <a> <em> <strong> <cite> <blockquote> <code> <ul> <ol> <li> <dl> <dt> <dd>
$safe = Xss::filter($user_input);

// Filter admin HTML — allows more tags for trusted admin content
$safe = Xss::filterAdmin($user_input);

// Escape URL — strips javascript:, vbscript: and other dangerous protocols
$safe_url = UrlHelper::stripDangerousProtocols($url);
```

### In Twig (Auto-escaped)

Twig automatically escapes all variables:

```twig
{# Automatically escaped - SAFE #}
{{ user_input }}
{{ title }}
{{ content }}

{# Manual escaping (rarely needed) #}
{{ user_input|escape }}
{{ user_input|e }}

{# Raw output - ONLY for trusted content #}
{{ trusted_content|raw }}

{# Translation with auto-escaping #}
{{ 'Hello @name'|t({'@name': user_name}) }}
```

### Render Arrays (Auto-escaped)

Render arrays automatically escape output:

```php
// Automatically escaped
$build = [
  '#markup' => $user_input, // SAFE - auto-escaped
];

// Plain text element (escaped)
$build = [
  '#plain_text' => $user_input, // SAFE - escaped as plain text
];

// Inline template (auto-escaped)
$build = [
  '#type' => 'inline_template',
  '#template' => '<div>{{ content }}</div>',
  '#context' => [
    'content' => $user_input, // SAFE - auto-escaped
  ],
];
```

## Input Validation

### Form Validation

```php
use Drupal\Core\Form\FormStateInterface;

public function validateForm(array &$form, FormStateInterface $form_state): void {
  // Email validation
  $email = $form_state->getValue('email');
  if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $form_state->setErrorByName('email', $this->t('Invalid email address.'));
  }

  // URL validation
  $url = $form_state->getValue('url');
  if (!filter_var($url, FILTER_VALIDATE_URL)) {
    $form_state->setErrorByName('url', $this->t('Invalid URL.'));
  }

  // Integer validation
  $age = $form_state->getValue('age');
  if (!is_numeric($age) || $age < 1 || $age > 120) {
    $form_state->setErrorByName('age', $this->t('Age must be between 1 and 120.'));
  }

  // Length validation
  $username = $form_state->getValue('username');
  if (strlen($username) < 3 || strlen($username) > 50) {
    $form_state->setErrorByName('username', $this->t('Username must be 3-50 characters.'));
  }

  // Pattern validation
  $username = $form_state->getValue('username');
  if (!preg_match('/^[a-zA-Z0-9_]+$/', $username)) {
    $form_state->setErrorByName('username', $this->t('Username can only contain letters, numbers, and underscores.'));
  }
}
```

### Sanitizing Input

```php
use Drupal\Component\Utility\Html;

// Remove HTML tags
$clean = strip_tags($input);

// Allow specific tags
$clean = strip_tags($input, '<p><a><strong><em>');

// Decode HTML entities
$decoded = Html::decodeEntities($input);

// Trim whitespace
$clean = trim($input);

// Normalize whitespace
$clean = preg_replace('/\s+/', ' ', trim($input));
```

## SQL Injection Prevention

### Always Use Placeholders

```php
// CORRECT - Uses placeholders
$result = $database->query('SELECT * FROM {users} WHERE name = :name', [
  ':name' => $user_input,
]);

// CORRECT - Query builder
$query = $database->select('users', 'u')
  ->fields('u')
  ->condition('u.name', $user_input);
$result = $query->execute();

// WRONG - Direct concatenation (SQL INJECTION VULNERABILITY!)
$result = $database->query("SELECT * FROM {users} WHERE name = '$user_input'");
```

### Entity Queries (Safe by Default)

```php
// Safe - parameters are automatically escaped
$query = $this->entityTypeManager->getStorage('node')->getQuery()
  ->accessCheck(TRUE)
  ->condition('type', $type)
  ->condition('title', $title);
$results = $query->execute();
```

## Access Control

### Permission-based Access

```php
use Drupal\Core\Session\AccountInterface;

// Check permission
if ($this->currentUser()->hasPermission('administer nodes')) {
  // User has permission
}

// Check multiple permissions (OR)
if ($this->currentUser()->hasPermission('edit any article content') ||
    $this->currentUser()->hasPermission('edit own article content')) {
  // User has at least one permission
}
```

### Entity Access Control

```php
use Drupal\Core\Access\AccessResult;

// Check entity access
if ($entity->access('view')) {
  // User can view
}

if ($entity->access('update')) {
  // User can edit
}

if ($entity->access('delete')) {
  // User can delete
}

// Check with specific account
if ($entity->access('update', $account)) {
  // Account can edit
}
```

### Route Access Control

In routing.yml:

```yaml
my_module.page:
  path: '/my-page'
  defaults:
    _controller: '\Drupal\my_module\Controller\MyController::page'
  requirements:
    _permission: 'access content'
    # OR
    _role: 'administrator'
    # OR
    _custom_access: '\Drupal\my_module\Access\MyAccessChecker::access'
```

### Custom Access Checker

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

Service definition:

```yaml
services:
  my_module.access_checker:
    class: Drupal\my_module\Access\MyAccessChecker
    tags:
      - { name: access_check, applies_to: _custom_access }
```

### Access Results with Cache Metadata

```php
use Drupal\Core\Access\AccessResult;

// Allow access
AccessResult::allowed()
  ->cachePerUser()
  ->addCacheTags(['config:my_module.settings']);

// Forbid access
AccessResult::forbidden('Reason')
  ->cachePerPermissions();

// Neutral (pass to next checker)
AccessResult::neutral();

// Conditional
AccessResult::allowedIf($condition)
  ->cachePerUser()
  ->addCacheableDependency($entity);

AccessResult::forbiddenIf($condition)
  ->cachePerPermissions();
```

## CSRF Protection

### Forms (Automatic)

Drupal forms automatically include CSRF tokens:

```php
// Forms are automatically protected
public function buildForm(array $form, FormStateInterface $form_state): array {
  // No manual CSRF token needed
  return $form;
}
```

### Custom Links/URLs

```php
use Drupal\Core\Url;

// Generate URL with CSRF token
$url = Url::fromRoute('my_module.action', ['id' => $id]);
$token = \Drupal::csrfToken()->get($url->getInternalPath());
$url->setOption('query', ['token' => $token]);

// Verify token
$token_valid = \Drupal::csrfToken()->validate($token, $path);
```

### Route with CSRF Requirement

```yaml
my_module.action:
  path: '/my-action/{id}'
  defaults:
    _controller: '\Drupal\my_module\Controller\MyController::action'
  requirements:
    _csrf_token: 'TRUE'
```

## File Upload Security

### Validate File Extensions

```php
use Drupal\file\FileInterface;

public function validateFile(FileInterface $file): array {
  $errors = [];

  // Allowed extensions
  $allowed = ['jpg', 'jpeg', 'png', 'gif'];
  $extension = pathinfo($file->getFilename(), PATHINFO_EXTENSION);

  if (!in_array(strtolower($extension), $allowed)) {
    $errors[] = t('Only @extensions files allowed.', [
      '@extensions' => implode(', ', $allowed),
    ]);
  }

  return $errors;
}
```

### Validate File Size

```php
$max_size = 5 * 1024 * 1024; // 5 MB
if ($file->getSize() > $max_size) {
  $errors[] = t('File size must be less than @size MB.', [
    '@size' => $max_size / 1024 / 1024,
  ]);
}
```

### Validate MIME Type

```php
$allowed_types = ['image/jpeg', 'image/png', 'image/gif'];
if (!in_array($file->getMimeType(), $allowed_types)) {
  $errors[] = t('Invalid file type.');
}
```

### Form Element File Validation

```php
$form['file'] = [
  '#type' => 'managed_file',
  '#title' => $this->t('Upload file'),
  '#upload_validators' => [
    'file_validate_extensions' => ['jpg jpeg png gif'],
    'file_validate_size' => [5 * 1024 * 1024], // 5 MB
  ],
  '#upload_location' => 'public://uploads/',
];
```

## XSS Prevention

### Never Use Raw Output

```php
// WRONG - XSS vulnerability
$build = [
  '#markup' => '<div>' . $user_input . '</div>',
];

// CORRECT - Use plain_text
$build = [
  '#plain_text' => $user_input,
];

// CORRECT - Use escaped markup
$build = [
  '#markup' => '<div>' . Html::escape($user_input) . '</div>',
];

// CORRECT - Use inline template
$build = [
  '#type' => 'inline_template',
  '#template' => '<div>{{ content }}</div>',
  '#context' => [
    'content' => $user_input, // Auto-escaped
  ],
];
```

### Filter User HTML

```php
use Drupal\Component\Utility\Xss;

// Allow limited HTML
$safe = Xss::filter($user_input);
// Allows: <a>, <em>, <strong>, <cite>, <blockquote>, <code>, <ul>, <ol>, <li>, <dl>, <dt>, <dd>

// Admin HTML (more tags)
$safe = Xss::filterAdmin($user_input);

// Custom allowed tags
$allowed_tags = ['<p>', '<a>', '<strong>', '<em>'];
$safe = strip_tags($user_input, implode('', $allowed_tags));
```

## Session Security

### Session Regeneration

```php
// Regenerate session after privilege escalation
\Drupal::service('session_manager')->regenerate();
```

### Secure Session Settings

In `settings.php`:

```php
// Force HTTPS for cookies
$settings['https'] = TRUE;

// HTTPOnly cookies
ini_set('session.cookie_httponly', 1);

// Secure cookies (HTTPS only)
ini_set('session.cookie_secure', 1);

// SameSite cookies
ini_set('session.cookie_samesite', 'Lax');
```

## Password Security

### Password Hashing (Automatic)

```php
use Drupal\user\Entity\User;

// Password is automatically hashed
$user = User::create([
  'name' => 'username',
  'pass' => 'plaintext_password', // Automatically hashed on save
]);
$user->save();
```

### Password Verification

```php
// Verify password
$password_valid = \Drupal::service('password')->check($plaintext, $hashed);
```

### Password Strength Requirements

In form validation:

```php
public function validateForm(array &$form, FormStateInterface $form_state): void {
  $password = $form_state->getValue('password');

  // Minimum length
  if (strlen($password) < 8) {
    $form_state->setErrorByName('password', $this->t('Password must be at least 8 characters.'));
  }

  // Require complexity
  if (!preg_match('/[A-Z]/', $password) ||
      !preg_match('/[a-z]/', $password) ||
      !preg_match('/[0-9]/', $password)) {
    $form_state->setErrorByName('password', $this->t('Password must contain uppercase, lowercase, and numbers.'));
  }
}
```

## Security Headers

### Add Security Headers

In `my_module.module` or event subscriber:

```php
use Symfony\Component\HttpKernel\Event\ResponseEvent;

public function onResponse(ResponseEvent $event): void {
  $response = $event->getResponse();

  // Content Security Policy
  $response->headers->set('Content-Security-Policy', "default-src 'self'");

  // X-Frame-Options (prevent clickjacking)
  $response->headers->set('X-Frame-Options', 'SAMEORIGIN');

  // X-Content-Type-Options
  $response->headers->set('X-Content-Type-Options', 'nosniff');

  // X-XSS-Protection
  $response->headers->set('X-XSS-Protection', '1; mode=block');

  // Referrer-Policy
  $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');
}
```

## Best Practices Checklist

1. ✅ **Escape all output** - Use auto-escaping in Twig, Html::escape() in PHP
2. ✅ **Validate all input** - Check type, length, format, pattern
3. ✅ **Use placeholders** - Never concatenate SQL queries
4. ✅ **Check access** - Verify permissions and entity access
5. ✅ **CSRF protection** - Use built-in form tokens
6. ✅ **Validate file uploads** - Check extension, size, MIME type
7. ✅ **Filter user HTML** - Use Xss::filter() or strip_tags()
8. ✅ **Hash passwords** - Use Drupal's password service
9. ✅ **Secure sessions** - HTTPOnly, Secure, SameSite cookies
10. ✅ **Add security headers** - CSP, X-Frame-Options, etc.
11. ✅ **Use HTTPS** - Enforce SSL in production
12. ✅ **Keep Drupal updated** - Apply security patches promptly
13. ✅ **Log security events** - Track failed login attempts, access violations
14. ✅ **Limit error messages** - Don't expose sensitive information
15. ✅ **Use dependency injection** - Avoid global functions in classes

## Common Vulnerabilities to Avoid

### ❌ SQL Injection
```php
// WRONG
$query = "SELECT * FROM users WHERE name = '$input'";
```

### ❌ XSS (Cross-Site Scripting)
```php
// WRONG
echo '<div>' . $_GET['input'] . '</div>';
```

### ❌ CSRF (Cross-Site Request Forgery)
```php
// WRONG - No token verification for state-changing operations
```

### ❌ Path Traversal
```php
// WRONG
$file = file_get_contents('/path/' . $_GET['file']);
```

### ❌ Insecure File Uploads
```php
// WRONG - No extension validation
$file->save();
```

### ❌ Missing Access Control
```php
// WRONG - No permission check
public function deletePage() {
  // Anyone can access
}
```

## Security Resources

- Drupal Security Team: https://www.drupal.org/security
- Security Advisories: https://www.drupal.org/security/advisories
- OWASP Top 10: https://owasp.org/www-project-top-ten/
- Security Best Practices: https://www.drupal.org/docs/security-in-drupal
