# Database API

## Core Concepts

The Database API provides a unified query interface supporting multiple database engines while protecting against SQL injection.

## Query Interface

### Simple Static Query

```php
$database = \Drupal::database();
$result = $database->query('SELECT * FROM {node_field_data} WHERE type = :type', [
  ':type' => 'article',
]);

foreach ($result as $record) {
  // Process record
}
```

**Important**: Always use:
- Curly braces `{table_name}` for table names
- Placeholders `:placeholder` for values

## SELECT Queries

### Basic SELECT

```php
$query = $database->select('node_field_data', 'n');
$query->fields('n', ['nid', 'title', 'created'])
  ->condition('n.type', 'article')
  ->condition('n.status', 1)
  ->orderBy('n.created', 'DESC')
  ->range(0, 10);

$result = $query->execute();
foreach ($result as $record) {
  // Process record
}
```

### SELECT with Joins

```php
$query = $database->select('node_field_data', 'n');
$query->leftJoin('users_field_data', 'u', 'n.uid = u.uid');
$query->fields('n', ['nid', 'title'])
  ->fields('u', ['name', 'mail'])
  ->condition('n.type', 'article')
  ->condition('n.status', 1);

$result = $query->execute();
```

### Advanced Conditions

```php
// OR conditions
$or = $query->orConditionGroup()
  ->condition('n.type', 'article')
  ->condition('n.type', 'blog');
$query->condition($or);

// Complex conditions
$and = $query->andConditionGroup()
  ->condition('n.status', 1)
  ->condition('n.promote', 1);
$query->condition($and);

// IN condition
$query->condition('n.nid', [1, 2, 3], 'IN');

// LIKE condition
$query->condition('n.title', '%drupal%', 'LIKE');

// NULL condition
$query->isNull('n.field_date');
$query->isNotNull('n.field_date');

// Comparison operators
$query->condition('n.created', strtotime('-1 week'), '>=');
```

### COUNT Queries

```php
$count = $database->select('node_field_data', 'n')
  ->condition('n.type', 'article')
  ->countQuery()
  ->execute()
  ->fetchField();
```

### DISTINCT

```php
$query = $database->select('node_field_data', 'n');
$query->fields('n', ['type'])
  ->distinct();
```

## INSERT Queries

### Single Insert

```php
$database->insert('my_table')
  ->fields([
    'name' => 'John',
    'email' => 'john@example.com',
    'created' => time(),
  ])
  ->execute();

// Get inserted ID
$id = $database->insert('my_table')
  ->fields([
    'name' => 'John',
  ])
  ->execute();
```

### Multiple Insert

```php
$query = $database->insert('my_table')
  ->fields(['name', 'email', 'created']);

foreach ($users as $user) {
  $query->values([
    'name' => $user['name'],
    'email' => $user['email'],
    'created' => time(),
  ]);
}

$query->execute();
```

## UPDATE Queries

### Basic UPDATE

```php
$database->update('my_table')
  ->fields([
    'status' => 'active',
    'updated' => time(),
  ])
  ->condition('id', $id)
  ->execute();

// Returns number of affected rows
$affected = $database->update('my_table')
  ->fields(['status' => 'inactive'])
  ->condition('created', strtotime('-1 year'), '<')
  ->execute();
```

### UPDATE with Expression

```php
use Drupal\Core\Database\Query\Expression;

$database->update('my_table')
  ->expression('counter', 'counter + 1')
  ->condition('id', $id)
  ->execute();
```

## DELETE Queries

### Basic DELETE

```php
$database->delete('my_table')
  ->condition('created', strtotime('-1 year'), '<')
  ->execute();

// Returns number of deleted rows
$deleted = $database->delete('my_table')
  ->condition('status', 'inactive')
  ->execute();
```

## Transactions

### Basic Transaction

```php
$transaction = $database->startTransaction();

try {
  // Multiple operations
  $database->insert('table1')
    ->fields(['name' => 'John'])
    ->execute();

  $database->update('table2')
    ->fields(['count' => 5])
    ->condition('id', 1)
    ->execute();

  // Transaction auto-commits when $transaction goes out of scope
}
catch (\Exception $e) {
  $transaction->rollback();
  throw $e;
}
```

### Named Transaction

```php
$transaction = $database->startTransaction('my_transaction');

try {
  // Operations
}
catch (\Exception $e) {
  $transaction->rollback();
  throw $e;
}
```

## MERGE Queries

Insert if not exists, update if exists:

```php
$database->merge('my_table')
  ->keys(['id' => $id])
  ->fields([
    'name' => 'John',
    'email' => 'john@example.com',
    'updated' => time(),
  ])
  ->execute();
```

## TRUNCATE

Delete all rows from a table:

```php
$database->truncate('my_table')->execute();
```

## Dependency Injection

### With Connection

```php
use Drupal\Core\Database\Connection;
use Symfony\Component\DependencyInjection\ContainerInterface;

class MyService {

  protected Connection $database;

  public function __construct(Connection $database) {
    $this->database = $database;
  }

  public static function create(ContainerInterface $container): static {
    return new static(
      $container->get('database')
    );
  }

  public function getArticles(): array {
    $query = $this->database->select('node_field_data', 'n');
    $query->fields('n', ['nid', 'title'])
      ->condition('n.type', 'article');

    return $query->execute()->fetchAll();
  }

}
```

## Fetch Methods

> **Drupal 11.2+ Deprecation**: `\PDO::FETCH_*` constants are deprecated in favour of the `Drupal\Core\Database\Statement\FetchAs` enum. Use `fetchAll()`, `fetchAssoc()`, `fetchObject()` etc. (documented below) — they automatically use the correct fetch mode. Only use `FetchAs` directly if you need to call `setFetchMode()` explicitly.
>
> ```php
> use Drupal\Core\Database\Statement\FetchAs;
>
> // Replaces PDO::FETCH_ASSOC
> $result->setFetchMode(FetchAs::Associative);
>
> // Replaces PDO::FETCH_OBJ
> $result->setFetchMode(FetchAs::ClassObject);
>
> // Replaces PDO::FETCH_COLUMN
> $result->setFetchMode(FetchAs::Column);
> ```

### fetchAll()

Returns all rows as array of objects:

```php
$rows = $query->execute()->fetchAll();
foreach ($rows as $row) {
  echo $row->title;
}
```

### fetchAssoc()

Returns next row as associative array:

```php
while ($row = $result->fetchAssoc()) {
  echo $row['title'];
}
```

### fetchObject()

Returns next row as object:

```php
while ($row = $result->fetchObject()) {
  echo $row->title;
}
```

### fetchField()

Returns single field from next row:

```php
$title = $result->fetchField();
```

### fetchCol()

Returns single column as array:

```php
$titles = $query->execute()->fetchCol();
```

### fetchAllKeyed()

Returns key-value pairs:

```php
// Returns ['nid' => 'title', ...]
$items = $query->execute()->fetchAllKeyed();
```

## Schema Operations

### Create Table

```php
$schema = $database->schema();

$table_schema = [
  'description' => 'My custom table',
  'fields' => [
    'id' => [
      'type' => 'serial',
      'not null' => TRUE,
      'description' => 'Primary Key',
    ],
    'name' => [
      'type' => 'varchar',
      'length' => 255,
      'not null' => TRUE,
      'description' => 'Name',
    ],
    'email' => [
      'type' => 'varchar',
      'length' => 255,
      'not null' => FALSE,
      'description' => 'Email',
    ],
    'created' => [
      'type' => 'int',
      'not null' => TRUE,
      'description' => 'Created timestamp',
    ],
  ],
  'primary key' => ['id'],
  'indexes' => [
    'name' => ['name'],
  ],
  'unique keys' => [
    'email' => ['email'],
  ],
];

$schema->createTable('my_table', $table_schema);
```

### Drop Table

```php
$schema->dropTable('my_table');
```

### Check if Table Exists

```php
if ($schema->tableExists('my_table')) {
  // Table exists
}
```

### Add Field

```php
$schema->addField('my_table', 'status', [
  'type' => 'varchar',
  'length' => 20,
  'not null' => TRUE,
  'default' => 'active',
]);
```

### Drop Field

```php
$schema->dropField('my_table', 'status');
```

## Best Practices

1. **Always use placeholders** for values (`:placeholder_name`)
2. **Enclose table names** in curly braces `{table_name}`
3. **Use dependency injection** for database service
4. **Prefer entity queries** for entity data
5. **Use transactions** for multi-step operations
6. **Never concatenate user input** into queries
7. **Use specific fetch methods** for better performance
8. **Check for empty results** before processing
9. **Log slow queries** for optimization
10. **Use database abstraction** for portability

## Entity Queries vs Database Queries

**Use Entity Queries when:**
- Querying entity data (nodes, users, taxonomy terms, etc.)
- Need automatic access checking
- Working with entity fields
- Need entity loading

**Use Database Queries when:**
- Complex joins across non-entity tables
- Custom tables
- Performance-critical queries
- Aggregate queries (COUNT, SUM, AVG)
- Direct table access needed

```php
// Entity Query (preferred for entities)
$query = $this->entityTypeManager->getStorage('node')->getQuery()
  ->accessCheck(TRUE)
  ->condition('type', 'article')
  ->condition('status', 1);
$nids = $query->execute();

// Database Query (for custom tables or complex joins)
$query = $this->database->select('my_custom_table', 'c')
  ->fields('c')
  ->condition('c.status', 'active');
$results = $query->execute();
```
