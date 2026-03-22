# Filtering and Queries Reference

Complete reference for filtering, sorting, pagination, includes, and sparse fieldsets in Drupal JSON:API.

## Filtering

### Simple Equality Filter (shorthand)

The simplest filter form uses `filter[field_name]=value`:

```bash
# Published content only
curl 'https://example.com/jsonapi/node/article?filter[status]=1'

# By title
curl 'https://example.com/jsonapi/node/article?filter[title]=My%20Article'

# By entity reference field (uses target_id)
curl 'https://example.com/jsonapi/node/article?filter[uid.meta.drupal_internal__target_id]=1'
```

### Full Filter Syntax (with operators)

For anything beyond simple equality, use the expanded filter syntax with a named filter group:

```bash
# CONTAINS operator
curl 'https://example.com/jsonapi/node/article?filter[title-filter][condition][path]=title&filter[title-filter][condition][operator]=CONTAINS&filter[title-filter][condition][value]=drupal'

# STARTS_WITH operator
curl 'https://example.com/jsonapi/node/article?filter[title-filter][condition][path]=title&filter[title-filter][condition][operator]=STARTS_WITH&filter[title-filter][condition][value]=How'

# Greater than (for dates, numbers)
curl 'https://example.com/jsonapi/node/article?filter[date-filter][condition][path]=created&filter[date-filter][condition][operator]=%3E&filter[date-filter][condition][value]=2025-01-01'
```

### Available Operators

| Operator | Description | URL-encoded |
| --- | --- | --- |
| `=` | Equal (default) | `%3D` |
| `<>` | Not equal | `%3C%3E` |
| `>` | Greater than | `%3E` |
| `>=` | Greater than or equal | `%3E%3D` |
| `<` | Less than | `%3C` |
| `<=` | Less than or equal | `%3C%3D` |
| `CONTAINS` | String contains | `CONTAINS` |
| `STARTS_WITH` | String starts with | `STARTS_WITH` |
| `ENDS_WITH` | String ends with | `ENDS_WITH` |
| `IN` | Value in list | `IN` |
| `NOT IN` | Value not in list | `NOT%20IN` |
| `BETWEEN` | Value between two values | `BETWEEN` |
| `IS NULL` | Field is null | `IS%20NULL` |
| `IS NOT NULL` | Field is not null | `IS%20NOT%20NULL` |

### IN Operator (multiple values)

```bash
# Articles with specific node IDs
curl 'https://example.com/jsonapi/node/article?filter[nid-filter][condition][path]=drupal_internal__nid&filter[nid-filter][condition][operator]=IN&filter[nid-filter][condition][value][]=1&filter[nid-filter][condition][value][]=2&filter[nid-filter][condition][value][]=3'
```

### IS NULL / IS NOT NULL

```bash
# Articles without an image
curl 'https://example.com/jsonapi/node/article?filter[no-image][condition][path]=field_image&filter[no-image][condition][operator]=IS%20NULL'

# Articles that have an image
curl 'https://example.com/jsonapi/node/article?filter[has-image][condition][path]=field_image&filter[has-image][condition][operator]=IS%20NOT%20NULL'
```

### Relationship (nested path) Filtering

Filter by properties of related entities using dot-notation paths:

```bash
# Articles by a specific author name
curl 'https://example.com/jsonapi/node/article?filter[uid.name]=admin'

# Articles tagged with a specific term name
curl 'https://example.com/jsonapi/node/article?filter[field_tags.name]=Drupal'

# Articles with a specific category ID
curl 'https://example.com/jsonapi/node/article?filter[field_category.meta.drupal_internal__target_id]=5'
```

### Filter Groups (AND / OR logic)

Combine multiple filters using groups:

```bash
# Published articles containing "drupal" in title (AND logic, default)
curl 'https://example.com/jsonapi/node/article?filter[status]=1&filter[title-filter][condition][path]=title&filter[title-filter][condition][operator]=CONTAINS&filter[title-filter][condition][value]=drupal'

# OR logic: articles that are either sticky OR promoted
curl 'https://example.com/jsonapi/node/article?filter[or-group][group][conjunction]=OR&filter[sticky-filter][condition][path]=sticky&filter[sticky-filter][condition][value]=1&filter[sticky-filter][condition][memberOf]=or-group&filter[promoted-filter][condition][path]=promote&filter[promoted-filter][condition][value]=1&filter[promoted-filter][condition][memberOf]=or-group'
```

## Sorting

### Single Field Sort

```bash
# Ascending (default)
curl 'https://example.com/jsonapi/node/article?sort=title'

# Descending (prefix with -)
curl 'https://example.com/jsonapi/node/article?sort=-created'
```

### Multiple Sort Criteria

Comma-separated, applied in order:

```bash
# Sticky first (descending), then newest first
curl 'https://example.com/jsonapi/node/article?sort=-sticky,-created'
```

### Sort by Relationship Field

```bash
# Sort by author name
curl 'https://example.com/jsonapi/node/article?sort=uid.name'
```

## Pagination

### Limit and Offset

```bash
# First 10 items
curl 'https://example.com/jsonapi/node/article?page[limit]=10&page[offset]=0'

# Next 10 items
curl 'https://example.com/jsonapi/node/article?page[limit]=10&page[offset]=10'
```

**Maximum page limit is 50.** Requesting more than 50 will be capped at 50. The default limit (when not specified) is also 50.

### Pagination Links

Responses include navigation links:

```json
{
  "links": {
    "self": { "href": "...?page[offset]=10&page[limit]=10" },
    "next": { "href": "...?page[offset]=20&page[limit]=10" },
    "prev": { "href": "...?page[offset]=0&page[limit]=10" }
  }
}
```

Always prefer using `links.next` from the response rather than manually computing offsets, as the server may adjust parameters.

## Includes (Related Entities)

Load related entities in a single request using `?include=`:

```bash
# Include the author and image
curl 'https://example.com/jsonapi/node/article?include=uid,field_image'

# Include nested relationships (image's file entity)
curl 'https://example.com/jsonapi/node/article?include=field_image,field_image.field_media_image'

# Include on a single entity
curl 'https://example.com/jsonapi/node/article/{uuid}?include=field_image,uid'
```

Included entities appear in the top-level `included` array:

```json
{
  "data": { ... },
  "included": [
    {
      "type": "user--user",
      "id": "user-uuid",
      "attributes": { "display_name": "Admin" }
    },
    {
      "type": "media--image",
      "id": "media-uuid",
      "attributes": { "name": "Hero image" }
    }
  ]
}
```

To find the included entity that matches a relationship, match `type` and `id` from `data.relationships.{field}.data` against the objects in `included`.

## Sparse Fieldsets

Request only specific fields to reduce response payload:

```bash
# Only return title and body for articles, display_name for users
curl 'https://example.com/jsonapi/node/article?fields[node--article]=title,body&fields[user--user]=display_name&include=uid'
```

The `fields` parameter uses the JSON:API type as the key (with `--` separator). Relationships that are not in the fieldset will be omitted from the response. Always include relationship fields in fieldsets if you need them.

## Combining Query Parameters

All query parameters can be combined:

```bash
curl 'https://example.com/jsonapi/node/article?filter[status]=1&sort=-created&page[limit]=5&include=field_image,uid&fields[node--article]=title,created,field_image'
```

This fetches the 5 most recently published articles, including their images and authors, returning only the title, created date, and image relationship for each article.
