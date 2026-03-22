# Drupal 11 Testing & Quality Assurance

Comprehensive guide to testing Drupal 11 modules using PHPUnit 9+, covering unit, kernel, and functional tests with modern PHP syntax.

## Test Base Classes

### When to Use Each Test Type

**Unit Tests (`UnitTestCase`)**
- Test isolated logic with no dependencies
- No database, no services, no Drupal bootstrap
- Fast execution (milliseconds)
- Use for: algorithms, calculations, data transformations
- **Example**: Testing a utility class that parses strings

**Kernel Tests (`KernelTestBase`)**
- Test with services and database available
- Minimal Drupal bootstrap
- Medium execution speed
- Use for: services, entity operations, database queries, API testing
- **Example**: Testing a custom service that loads and manipulates entities

**Functional Tests (`BrowserTestBase`)**
- Full Drupal bootstrap with browser simulation
- Test complete HTTP request/response cycles
- Slower execution (seconds per test)
- Use for: forms, user workflows, access control, full page rendering
- **Example**: Testing a multi-step form submission

## Unit Tests

### Basic Unit Test Structure

```php
<?php

namespace Drupal\my_module\Tests\Unit;

use Drupal\Tests\UnitTestCase;
use Drupal\my_module\Service\MyService;

/**
 * Tests for MyService.
 *
 * @group my_module
 * @coversDefaultClass \Drupal\my_module\Service\MyService
 */
class MyServiceTest extends UnitTestCase {

  /**
   * The service under test.
   */
  protected MyService $service;

  /**
   * {@inheritdoc}
   */
  protected function setUp(): void {
    parent::setUp();
    // Create instance with mocked dependencies
    $this->service = new MyService();
  }

  /**
   * Tests basic functionality.
   *
   * @covers ::myMethod
   */
  public function testMyMethod(): void {
    $result = $this->service->myMethod('input');
    $this->assertEquals('expected', $result);
  }

}
```

### Data Providers (PHPUnit 9+ Syntax)

```php
/**
 * Data provider for testCalculation().
 */
public static function provideCalculationData(): array {
  return [
    'basic addition' => [4, 2, 2],
    'negative numbers' => [0, 5, -5],
    'zero result' => [0, 0, 0],
  ];
}

/**
 * Tests calculation with various inputs.
 *
 * @dataProvider provideCalculationData
 * @covers ::calculate
 */
public function testCalculation(int $expected, int $a, int $b): void {
  $result = $this->service->calculate($a, $b);
  $this->assertEquals($expected, $result);
}
```

### Mocking Dependencies

**Simple Mock:**
```php
// Mock a simple class
$mock = $this->createMock(DependencyClass::class);
```

**Mock with Method Expectations:**
```php
// Create mock and set method expectations
$mockLogger = $this->createMock(LoggerInterface::class);
$mockLogger->expects($this->once())
  ->method('error')
  ->with($this->equalTo('Error message'));

$service = new MyService($mockLogger);
```

**Mock Builder for Complex Mocking:**
```php
$mockService = $this->getMockBuilder(ComplexService::class)
  ->setConstructorArgs([$dependency1, $dependency2])
  ->onlyMethods(['methodToMock'])
  ->getMock();

$mockService->expects($this->once())
  ->method('methodToMock')
  ->with($this->equalTo('input'))
  ->willReturn('output');
```

**Mocking Translation Service:**
```php
// Common in Drupal - mock string translation
$mockTranslation = $this->getStringTranslationStub();
$controller = new MyController($mockTranslation);
```

### Testing Protected/Private Methods

```php
// Use reflection to access protected/private methods
$method = new \ReflectionMethod($object, 'protectedMethod');
$method->setAccessible(TRUE);
$result = $method->invokeArgs($object, [$arg1, $arg2]);
$this->assertEquals('expected', $result);
```

## Kernel Tests

### Basic Kernel Test Structure

> **REQUIRED in Drupal 11.3+**: All `KernelTestBase` and `BrowserTestBase` test classes MUST include the `#[RunTestsInSeparateProcesses]` attribute. Omitting it is deprecated in Drupal 11.3.0 and will cause failures in Drupal 12.0.0.

```php
<?php

namespace Drupal\Tests\my_module\Kernel;

use Drupal\KernelTests\KernelTestBase;
use Drupal\Tests\node\Traits\NodeCreationTrait;
use Drupal\Tests\user\Traits\UserCreationTrait;
use PHPUnit\Framework\Attributes\RunTestsInSeparateProcesses;

/**
 * Tests MyModule functionality.
 *
 * @group my_module
 */
#[RunTestsInSeparateProcesses]
class MyModuleTest extends KernelTestBase {

  use NodeCreationTrait;
  use UserCreationTrait;

  /**
   * Modules to enable.
   *
   * @var string[]
   */
  protected static $modules = [
    'user',
    'system',
    'node',
    'my_module',
  ];

  /**
   * {@inheritdoc}
   */
  protected function setUp(): void {
    parent::setUp();

    // Install required schema
    $this->installSchema('system', ['sequences']);
    $this->installSchema('node', ['node_access']);
    $this->installSchema('user', ['users_data']);

    // Install entity schemas
    $this->installEntitySchema('user');
    $this->installEntitySchema('node');

    // Install configuration
    $this->installConfig(['system', 'node', 'user', 'my_module']);

    // Create test fixtures
    $this->createContentType(['type' => 'article']);
  }

  /**
   * Tests entity creation and manipulation.
   */
  public function testEntityOperations(): void {
    // Create test user
    $user = $this->createUser([], 'test_user');
    $this->assertEquals('test_user', $user->getAccountName());

    // Create test node
    $node = $this->createNode([
      'type' => 'article',
      'title' => 'Test Node',
      'uid' => $user->id(),
    ]);

    $this->assertEquals('Test Node', $node->getTitle());
    $this->assertEquals($user->id(), $node->getOwnerId());
  }

  /**
   * Tests service integration.
   */
  public function testServiceIntegration(): void {
    // Access services via container
    $service = $this->container->get('my_module.my_service');
    $result = $service->doSomething();

    $this->assertNotNull($result);
  }

}
```

### Installing Schema and Config

```php
// Install module schema (hook_schema tables)
$this->installSchema('my_module', ['my_custom_table']);

// Install entity schema
$this->installEntitySchema('node');
$this->installEntitySchema('user');
$this->installEntitySchema('taxonomy_term');

// Install configuration
$this->installConfig(['my_module', 'node', 'user']);
```

### Common Kernel Test Traits

```php
use Drupal\Tests\node\Traits\NodeCreationTrait;  // $this->createNode()
use Drupal\Tests\user\Traits\UserCreationTrait;  // $this->createUser()
use Drupal\Tests\field\Traits\EntityReferenceTestTrait;  // Entity reference helpers
```

## Functional Tests

### Basic Functional Test Structure

```php
<?php

namespace Drupal\Tests\my_module\Functional;

use Drupal\Tests\BrowserTestBase;
use PHPUnit\Framework\Attributes\RunTestsInSeparateProcesses;

/**
 * Tests MyModule user interface.
 *
 * @group my_module
 */
#[RunTestsInSeparateProcesses]
class MyModuleFunctionalTest extends BrowserTestBase {

  /**
   * {@inheritdoc}
   */
  protected $defaultTheme = 'stark';

  /**
   * Modules to enable.
   *
   * @var string[]
   */
  protected static $modules = ['my_module', 'node', 'user'];

  /**
   * Admin user for testing.
   */
  protected $adminUser;

  /**
   * {@inheritdoc}
   */
  protected function setUp(): void {
    parent::setUp();

    // Create content type
    $this->createContentType(['type' => 'article']);

    // Create test users
    $this->adminUser = $this->drupalCreateUser([
      'access content',
      'create article content',
      'edit own article content',
      'administer nodes',
    ]);
  }

  /**
   * Tests form submission workflow.
   */
  public function testFormSubmission(): void {
    $assert = $this->assertSession();

    // Log in as admin
    $this->drupalLogin($this->adminUser);

    // Navigate to form
    $this->drupalGet('node/add/article');
    $assert->statusCodeEquals(200);

    // Fill and submit form
    $edit = [
      'title[0][value]' => 'Test Article',
      'body[0][value]' => 'Test body content',
    ];
    $this->submitForm($edit, 'Save');

    // Verify success
    $assert->statusCodeEquals(200);
    $assert->pageTextContains('Test Article');
    $assert->pageTextContains('has been created');
  }

}
```

### Browser Interaction Methods

```php
// Navigation
$this->drupalGet('path/to/page');
$this->drupalGet($node->toUrl());

// User authentication
$this->drupalLogin($user);
$this->drupalLogout();

// Form interaction
$this->submitForm($form_data, 'Submit button text');
$this->submitForm($edit, 'op');  // 'op' for default submit button

// Link clicking
$this->clickLink('Link text');
```

### Assertions with WebAssert

```php
$assert = $this->assertSession();

// HTTP status
$assert->statusCodeEquals(200);
$assert->statusCodeEquals(403);  // Access denied

// Page content
$assert->pageTextContains('Expected text');
$assert->pageTextNotContains('Unexpected text');
$assert->pageTextMatches('/regex pattern/');

// Links
$assert->linkExists('Link text');
$assert->linkNotExists('Missing link');
$assert->linkByHrefExists('/path/to/page');

// Form fields
$assert->fieldExists('field_name');
$assert->fieldValueEquals('field_name', 'expected value');
$assert->buttonExists('Button text');

// Elements
$assert->elementExists('css', '.my-class');
$assert->elementAttributeContains('css', 'input[name="title"]', 'value', 'Test');

// Page title
$assert->titleEquals('Page Title | Site Name');

// Response headers
$assert->responseHeaderEquals('Content-Type', 'text/html; charset=UTF-8');
```

### Working with Page Elements

```php
// Get page session
$page = $this->getSession()->getPage();

// Find elements
$element = $page->find('css', '.my-selector');
$element = $page->find('xpath', '//div[@class="test"]');

// Element interaction
$element->click();
$element->getValue();
$element->getText();
$element->hasClass('active');
```

### Creating Test Content

```php
// Create node via API (faster than UI)
$node = $this->drupalCreateNode([
  'type' => 'article',
  'title' => 'Test Node',
  'body' => [
    [
      'value' => 'Body text',
      'format' => filter_default_format(),
    ],
  ],
]);

// Get node by title
$node = $this->drupalGetNodeByTitle('Test Node');
```

## Testing Cache Functionality

### Cache Invalidation Testing

```php
/**
 * Tests cache invalidation.
 */
public function testCacheInvalidation(): void {
  $assert = $this->assertSession();

  // First visit - should not be cached
  $this->drupalGet('my-cached-page');
  $assert->pageTextContains('Source: actual data');

  // Second visit - should be cached
  $this->drupalGet('my-cached-page');
  $assert->pageTextContains('Source: cached');

  // Trigger cache invalidation
  \Drupal::service('cache_tags.invalidator')
    ->invalidateTags(['my_cache_tag']);

  // Third visit - cache should be rebuilt
  $this->drupalGet('my-cached-page');
  $assert->pageTextContains('Source: actual data');
}
```

### Testing Cache Tags

```php
/**
 * Tests cache tag invalidation.
 */
public function testCacheTags(): void {
  $cache = \Drupal::cache();

  // Create cached item with tags
  $cache->set('my_cache_key', 'cached data', time() + 3600, [
    'my_module:item:1',
    'my_module:list',
  ]);

  // Verify cache exists
  $cached = $cache->get('my_cache_key');
  $this->assertNotFalse($cached);
  $this->assertEquals('cached data', $cached->data);

  // Invalidate by tag
  \Drupal::service('cache_tags.invalidator')
    ->invalidateTags(['my_module:item:1']);

  // Verify cache is invalidated
  $cached = $cache->get('my_cache_key');
  $this->assertFalse($cached);
}
```

### Testing Cache Contexts

```php
/**
 * Tests cache varies by user role.
 */
public function testCacheContexts(): void {
  // Test as anonymous
  $this->drupalGet('my-role-dependent-page');
  $anonymousContent = $this->getSession()->getPage()->getHtml();

  // Test as authenticated user
  $user = $this->drupalCreateUser();
  $this->drupalLogin($user);
  $this->drupalGet('my-role-dependent-page');
  $userContent = $this->getSession()->getPage()->getHtml();

  // Content should differ based on cache context
  $this->assertNotEquals($anonymousContent, $userContent);
}
```

## Common Assertions

### Entity Assertions
```php
$this->assertNotNull($entity);
$this->assertEquals('expected', $entity->label());
$this->assertTrue($entity->access('view', $user));
$this->assertFalse($entity->isNew());
```

### Array Assertions
```php
$this->assertIsArray($result);
$this->assertCount(5, $result);
$this->assertArrayHasKey('key', $result);
$this->assertContains('value', $result);
$this->assertEmpty($result);
$this->assertNotEmpty($result);
```

### String Assertions
```php
$this->assertStringContainsString('needle', $haystack);
$this->assertStringStartsWith('prefix', $string);
$this->assertStringEndsWith('suffix', $string);
$this->assertMatchesRegularExpression('/pattern/', $string);
```

### Type Assertions (PHPUnit 9+)
```php
$this->assertIsString($value);
$this->assertIsInt($value);
$this->assertIsBool($value);
$this->assertIsArray($value);
$this->assertIsObject($value);
$this->assertInstanceOf(NodeInterface::class, $node);
```

## Test Organization Best Practices

### Group Related Tests
```php
/**
 * @group my_module
 * @group my_module_api
 */
```

### Use setUp() for Common Initialization
```php
protected function setUp(): void {
  parent::setUp();

  // Create fixtures used by multiple tests
  $this->testUser = $this->createUser();
  $this->testNode = $this->createNode(['type' => 'article']);
}
```

### Use tearDown() for Cleanup (if needed)
```php
protected function tearDown(): void {
  // Clean up resources
  unset($this->testUser);
  parent::tearDown();
}
```

### Test Method Naming
```php
// Good: Describes what is being tested
public function testUserCanCreateArticle(): void {}
public function testAccessDeniedForAnonymous(): void {}
public function testFormValidationRequiresTitle(): void {}

// Bad: Generic names
public function testOne(): void {}
public function testFunction(): void {}
```

## Code Coverage

### Annotations for Coverage
```php
/**
 * @coversDefaultClass \Drupal\my_module\Service\MyService
 */
class MyServiceTest extends UnitTestCase {

  /**
   * @covers ::myMethod
   * @covers ::helperMethod
   */
  public function testMyMethod(): void {
    // Test implementation
  }

}
```

## Drupal 11 / PHPUnit 9+ Modern Syntax

### Return Type Declarations
```php
// Always declare void for test methods
public function testSomething(): void {
  // Test code
}

// Use specific return types for data providers
public static function provideTestData(): array {
  return [/* data */];
}
```

### Static Data Providers
```php
// PHPUnit 10+ requires static data providers
public static function provideTestData(): array {
  return [
    'case 1' => [1, 2, 3],
    'case 2' => [4, 5, 9],
  ];
}
```

### Assertion Methods (Modern)
```php
// Use typed assertion methods
$this->assertIsInt($value);        // Not assertInternalType
$this->assertIsString($value);     // Not assertInternalType
$this->assertStringContainsString($needle, $haystack);  // Not assertContains
$this->assertMatchesRegularExpression($pattern, $string);  // Not assertRegExp
```

## Example Test Class Template

```php
<?php

namespace Drupal\Tests\my_module\[Unit|Kernel|Functional];

use Drupal\Tests\[UnitTestCase|KernelTestBase|BrowserTestBase];
// Required for KernelTestBase and BrowserTestBase (not needed for UnitTestCase)
use PHPUnit\Framework\Attributes\RunTestsInSeparateProcesses;

/**
 * Tests [feature description].
 *
 * @group my_module
 * @coversDefaultClass \Drupal\my_module\[ClassName]
 */
#[RunTestsInSeparateProcesses] // Required for KernelTestBase / BrowserTestBase
class [ClassName]Test extends [TestBase] {

  /**
   * {@inheritdoc}
   */
  protected static $modules = ['my_module'];

  /**
   * {@inheritdoc}
   */
  protected function setUp(): void {
    parent::setUp();

    // Setup test fixtures
  }

  /**
   * Tests [specific functionality].
   *
   * @covers ::[methodName]
   */
  public function test[Functionality](): void {
    // Arrange
    $input = 'test data';

    // Act
    $result = $this->service->method($input);

    // Assert
    $this->assertEquals('expected', $result);
  }

}
```

## Quick Reference

**Test Type Selection:**
- No Drupal? → Unit Test
- Need database/services? → Kernel Test
- Need HTTP/forms/browser? → Functional Test

**Common Operations:**
- Mock service → `$this->createMock(ServiceInterface::class)`
- Create user → `$this->createUser()` (kernel/functional)
- Create node → `$this->createNode([])` (kernel/functional)
- Visit page → `$this->drupalGet('path')` (functional)
- Submit form → `$this->submitForm($edit, 'button')` (functional)
- Assert text → `$this->assertSession()->pageTextContains('text')` (functional)

**Resources:**
- Testing API: https://api.drupal.org/api/drupal/core!tests!README.md
- PHPUnit Docs: https://phpunit.readthedocs.io/
- Drupal Examples: https://git.drupalcode.org/project/examples/-/tree/4.0.x/modules/testing_example
