# CRUD Operations Reference

Complete examples for Create, Read, Update, and Delete operations via Drupal's JSON:API.

## Required Headers

All write operations (POST, PATCH, DELETE) require:

```
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
```

For cookie-based authentication, also include:

```
X-CSRF-Token: {token from /session/token}
```

## List Entities (GET collection)

```bash
# List all published articles
curl 'https://example.com/jsonapi/node/article?filter[status]=1'

# List with includes, sorting, and pagination
curl 'https://example.com/jsonapi/node/article?include=field_image,uid&sort=-created&page[limit]=10'

# Discover available resource types
curl https://example.com/jsonapi
```

The root `/jsonapi` endpoint returns a list of all available resource types and their URLs.

### Response Structure

```json
{
  "jsonapi": { "version": "1.0", "meta": { "links": { "self": { "href": "http://jsonapi.org/format/1.0/" } } } },
  "data": [
    {
      "type": "node--article",
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "attributes": {
        "title": "My Article",
        "status": true,
        "created": "2025-01-15T10:30:00+00:00",
        "body": {
          "value": "<p>Article content</p>",
          "format": "full_html",
          "processed": "<p>Article content</p>",
          "summary": ""
        }
      },
      "relationships": {
        "field_image": {
          "data": {
            "type": "media--image",
            "id": "660e8400-e29b-41d4-a716-446655440001",
            "meta": { "drupal_internal__target_id": 42 }
          }
        },
        "uid": {
          "data": {
            "type": "user--user",
            "id": "770e8400-e29b-41d4-a716-446655440002"
          }
        }
      },
      "links": {
        "self": { "href": "https://example.com/jsonapi/node/article/550e8400-e29b-41d4-a716-446655440000" }
      }
    }
  ],
  "included": [],
  "links": {
    "self": { "href": "https://example.com/jsonapi/node/article?page[limit]=10" },
    "next": { "href": "https://example.com/jsonapi/node/article?page[offset]=10&page[limit]=10" }
  }
}
```

## Get Single Entity (GET)

```bash
# Fetch a specific article by UUID
curl https://example.com/jsonapi/node/article/550e8400-e29b-41d4-a716-446655440000

# With includes
curl 'https://example.com/jsonapi/node/article/550e8400-e29b-41d4-a716-446655440000?include=field_image,uid'

# With sparse fieldsets (only return specific fields)
curl 'https://example.com/jsonapi/node/article/550e8400-e29b-41d4-a716-446655440000?fields[node--article]=title,body'
```

### Response Structure (single entity)

```json
{
  "data": {
    "type": "node--article",
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "attributes": { ... },
    "relationships": { ... }
  }
}
```

## Create Entity (POST)

POST to the collection endpoint. The server assigns the UUID.

### Create a Node

```bash
curl -X POST https://example.com/jsonapi/node/article \
  -H "Content-Type: application/vnd.api+json" \
  -H "Accept: application/vnd.api+json" \
  -d '{
    "data": {
      "type": "node--article",
      "attributes": {
        "title": "New Article",
        "status": true,
        "body": {
          "value": "<p>Article body content.</p>",
          "format": "full_html"
        },
        "path": {
          "alias": "/new-article"
        }
      },
      "relationships": {
        "field_image": {
          "data": {
            "type": "media--image",
            "id": "660e8400-e29b-41d4-a716-446655440001"
          }
        }
      }
    }
  }'
```

### Create a Taxonomy Term

```bash
curl -X POST https://example.com/jsonapi/taxonomy_term/tags \
  -H "Content-Type: application/vnd.api+json" \
  -H "Accept: application/vnd.api+json" \
  -d '{
    "data": {
      "type": "taxonomy_term--tags",
      "attributes": {
        "name": "Drupal",
        "description": {
          "value": "Content about Drupal",
          "format": "basic_html"
        }
      }
    }
  }'
```

### Create with Client-Generated UUID

You can provide your own UUID in the POST body:

```bash
curl -X POST https://example.com/jsonapi/node/article \
  -H "Content-Type: application/vnd.api+json" \
  -d '{
    "data": {
      "type": "node--article",
      "id": "my-custom-uuid-here",
      "attributes": {
        "title": "Article with custom UUID"
      }
    }
  }'
```

## Update Entity (PATCH)

PATCH to the individual entity endpoint. You must include `data.type` and `data.id`. Only send the fields you want to change.

```bash
curl -X PATCH https://example.com/jsonapi/node/article/550e8400-e29b-41d4-a716-446655440000 \
  -H "Content-Type: application/vnd.api+json" \
  -H "Accept: application/vnd.api+json" \
  -d '{
    "data": {
      "type": "node--article",
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "attributes": {
        "title": "Updated Article Title",
        "body": {
          "value": "<p>Updated body content.</p>",
          "format": "full_html"
        }
      }
    }
  }'
```

### Update Relationships

Update entity references via the relationship endpoint:

```bash
# Set a single-value relationship (e.g., cover image)
curl -X PATCH https://example.com/jsonapi/node/article/550e8400-e29b-41d4-a716-446655440000/relationships/field_image \
  -H "Content-Type: application/vnd.api+json" \
  -d '{
    "data": {
      "type": "media--image",
      "id": "660e8400-e29b-41d4-a716-446655440001"
    }
  }'

# Set a multi-value relationship (e.g., tags)
curl -X PATCH https://example.com/jsonapi/node/article/550e8400-e29b-41d4-a716-446655440000/relationships/field_tags \
  -H "Content-Type: application/vnd.api+json" \
  -d '{
    "data": [
      { "type": "taxonomy_term--tags", "id": "tag-uuid-1" },
      { "type": "taxonomy_term--tags", "id": "tag-uuid-2" }
    ]
  }'

# Add to a multi-value relationship (without removing existing)
curl -X POST https://example.com/jsonapi/node/article/550e8400-e29b-41d4-a716-446655440000/relationships/field_tags \
  -H "Content-Type: application/vnd.api+json" \
  -d '{
    "data": [
      { "type": "taxonomy_term--tags", "id": "tag-uuid-3" }
    ]
  }'

# Remove from a multi-value relationship
curl -X DELETE https://example.com/jsonapi/node/article/550e8400-e29b-41d4-a716-446655440000/relationships/field_tags \
  -H "Content-Type: application/vnd.api+json" \
  -d '{
    "data": [
      { "type": "taxonomy_term--tags", "id": "tag-uuid-1" }
    ]
  }'
```

## Delete Entity (DELETE)

```bash
curl -X DELETE https://example.com/jsonapi/node/article/550e8400-e29b-41d4-a716-446655440000 \
  -H "Accept: application/vnd.api+json"
```

A successful delete returns HTTP 204 No Content with an empty body.

## Error Handling

JSON:API errors follow a standard structure:

```json
{
  "errors": [
    {
      "title": "Forbidden",
      "status": "403",
      "detail": "The current user is not allowed to PATCH the selected field (field_name).",
      "source": {
        "pointer": "/data/attributes/field_name"
      }
    }
  ]
}
```

Common HTTP status codes:

| Code | Meaning |
| --- | --- |
| 200 | Success (GET, PATCH) |
| 201 | Created (POST) |
| 204 | No Content (DELETE) |
| 400 | Bad Request (malformed payload, missing required field) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Not Found (wrong UUID or resource type) |
| 405 | Method Not Allowed (read-only mode or restricted endpoint) |
| 409 | Conflict (type mismatch, duplicate UUID) |
| 415 | Unsupported Media Type (wrong Content-Type header) |
| 422 | Unprocessable Entity (validation error, e.g., required field missing) |
