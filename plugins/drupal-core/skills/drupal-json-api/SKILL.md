---
name: drupal-json-api
description: Drupal JSON:API module patterns for AI agents. Covers CRUD operations, filtering, sorting, pagination, includes, media upload, formatted text fields, path aliases, and common pitfalls. Use when interacting with Drupal content via the JSON:API.
---

# Drupal JSON:API Skill

This skill provides patterns and reference for interacting with Drupal content via the core JSON:API module. All operations use standard HTTP requests against `/jsonapi/` endpoints.

## URL Structure

Drupal's JSON:API uses a predictable URL pattern based on entity type and bundle:

```
/jsonapi/{entity_type_id}/{bundle}
```

Examples:

| Entity | URL Path |
| --- | --- |
| Article nodes | `/jsonapi/node/article` |
| Page nodes | `/jsonapi/node/page` |
| Image media | `/jsonapi/media/image` |
| File entities | `/jsonapi/file/file` |
| Tags vocabulary | `/jsonapi/taxonomy_term/tags` |
| Categories vocabulary | `/jsonapi/taxonomy_term/categories` |
| Users | `/jsonapi/user/user` |
| Menu link content | `/jsonapi/menu_link_content/main` |

In JSON:API type identifiers, the separator is `--` (e.g., `node--article`, `media--image`, `taxonomy_term--tags`). In URL paths, the separator is `/`.

Single-entity operations append the UUID: `/jsonapi/node/article/{uuid}`.

## Authentication

Drupal JSON:API supports several authentication methods depending on site configuration.

**Cookie-based (session):** Obtain a session cookie via form login, then include it in requests. Requires a CSRF token from `/session/token` for write operations.

```bash
# Get CSRF token
TOKEN=$(curl -s https://example.com/session/token)

# Write request with cookie + CSRF token
curl -X POST https://example.com/jsonapi/node/article \
  -H "Content-Type: application/vnd.api+json" \
  -H "X-CSRF-Token: $TOKEN" \
  -b "session_cookie" \
  -d @payload.json
```

**Basic Auth:** Enable the `basic_auth` module. Pass credentials with each request.

```bash
curl -u admin:password https://example.com/jsonapi/node/article
```

**OAuth 2.0:** Use the `simple_oauth` module. Obtain a bearer token and include it in headers.

```bash
# Obtain token
TOKEN=$(curl -s -X POST https://example.com/oauth/token \
  -d "grant_type=client_credentials&client_id=ID&client_secret=SECRET" \
  | jq -r '.access_token')

# Authenticated request
curl -H "Authorization: Bearer $TOKEN" \
  https://example.com/jsonapi/node/article
```

## CRUD Operations

See [references/crud-operations.md](references/crud-operations.md) for complete examples.

### List (GET collection)

```bash
curl https://example.com/jsonapi/node/article
```

### Get single entity (GET)

```bash
curl https://example.com/jsonapi/node/article/{uuid}
```

### Create (POST)

```bash
curl -X POST https://example.com/jsonapi/node/article \
  -H "Content-Type: application/vnd.api+json" \
  -H "Accept: application/vnd.api+json" \
  -d '{
    "data": {
      "type": "node--article",
      "attributes": {
        "title": "My Article",
        "status": true
      }
    }
  }'
```

### Update (PATCH)

```bash
curl -X PATCH https://example.com/jsonapi/node/article/{uuid} \
  -H "Content-Type: application/vnd.api+json" \
  -H "Accept: application/vnd.api+json" \
  -d '{
    "data": {
      "type": "node--article",
      "id": "{uuid}",
      "attributes": {
        "title": "Updated Title"
      }
    }
  }'
```

### Delete (DELETE)

```bash
curl -X DELETE https://example.com/jsonapi/node/article/{uuid}
```

## Filtering, Sorting, and Pagination

See [references/filtering-and-queries.md](references/filtering-and-queries.md) for the full reference.

### Filtering

```bash
# Simple equality
curl 'https://example.com/jsonapi/node/article?filter[status]=1'

# With operator
curl 'https://example.com/jsonapi/node/article?filter[title-filter][condition][path]=title&filter[title-filter][condition][operator]=CONTAINS&filter[title-filter][condition][value]=drupal'

# Relationship filtering
curl 'https://example.com/jsonapi/node/article?filter[uid.name]=admin'
```

### Sorting

```bash
# Sort ascending by title
curl 'https://example.com/jsonapi/node/article?sort=title'

# Sort descending by created date
curl 'https://example.com/jsonapi/node/article?sort=-created'

# Multiple sort criteria
curl 'https://example.com/jsonapi/node/article?sort=-sticky,-created'
```

### Pagination

```bash
curl 'https://example.com/jsonapi/node/article?page[limit]=10&page[offset]=0'
```

The response includes `links.next` and `links.prev` for navigating pages. Default page limit is 50, maximum is 50.

### Includes (related entities)

```bash
# Include referenced entities
curl 'https://example.com/jsonapi/node/article?include=field_image,uid'

# Nested includes
curl 'https://example.com/jsonapi/node/article?include=field_image,field_image.thumbnail'
```

Included entities appear in the top-level `included` array of the response.

### Sparse Fieldsets

Limit which fields are returned to reduce payload size:

```bash
curl 'https://example.com/jsonapi/node/article?fields[node--article]=title,body,created&fields[user--user]=display_name'
```

## Media Handling

See [references/media-handling.md](references/media-handling.md) for the full reference including file upload.

### Media vs File Entity IDs (Critical)

When working with media entities (images, documents, videos), there are two different internal IDs that are easy to confuse:

| Entity Type | ID Location | Usage |
| --- | --- | --- |
| **File** | `drupal_internal__fid` in the file entity | Internal file storage reference |
| **Media** | `drupal_internal__mid` in the media entity | **Use this for entity reference fields** |

Using the file's internal ID instead of the media's internal ID is a common mistake that causes "entity not found" or null-value errors.

### File Upload (two-step process)

1. Upload the binary file to create a file entity.
2. Create a media entity referencing the file.

```bash
# Step 1: Upload file
curl -X POST https://example.com/jsonapi/media/image/field_media_image \
  -H "Content-Type: application/octet-stream" \
  -H "Accept: application/vnd.api+json" \
  -H "Content-Disposition: file; filename=\"photo.jpg\"" \
  --data-binary @photo.jpg

# Step 2: Create media entity (use file UUID from step 1 response)
curl -X POST https://example.com/jsonapi/media/image \
  -H "Content-Type: application/vnd.api+json" \
  -d '{
    "data": {
      "type": "media--image",
      "attributes": {
        "name": "Photo description"
      },
      "relationships": {
        "field_media_image": {
          "data": {
            "type": "file--file",
            "id": "{file-uuid-from-step-1}",
            "meta": {
              "alt": "Alt text for the image"
            }
          }
        }
      }
    }
  }'
```

### Formatted Text Fields (body, description, etc.)

Rich text fields require both a `value` and a `format`:

```json
{
  "body": {
    "value": "<p>HTML content with <a href=\"/page\">links</a>.</p>",
    "format": "full_html"
  }
}
```

Common text formats: `full_html`, `basic_html`, `restricted_html`, `plain_text`. The available formats depend on the site's configuration. Always check the site's text format settings at `/admin/config/content/formats`.

### Referencing Media in Entity Fields

Entity reference fields to media use the relationship structure:

```json
{
  "data": {
    "type": "node--article",
    "attributes": {
      "title": "My Article"
    },
    "relationships": {
      "field_image": {
        "data": {
          "type": "media--image",
          "id": "{media-uuid}"
        }
      }
    }
  }
}
```

## Path Alias Management

Set URL aliases when creating or updating content via the `path` attribute:

```json
{
  "data": {
    "type": "node--article",
    "attributes": {
      "title": "About Us",
      "path": {
        "alias": "/about-us"
      }
    }
  }
}
```

Path aliases must begin with `/`. Aliases are managed at `/admin/config/search/path` in the admin UI.

## Menu Management

Drupal exposes menu link content entities via JSON:API at `/jsonapi/menu_link_content/{menu_name}`. However, **menu endpoints are often read-only** depending on the site's configuration. Many Drupal distributions restrict write access to menus via the API.

### Listing Menu Items (read-only)

```bash
curl https://example.com/jsonapi/menu_link_content/main
curl https://example.com/jsonapi/menu_link_content/footer
```

### Managing Menu Items (admin UI)

If the API returns 405 Method Not Allowed for POST/PATCH/DELETE, manage menus through the admin UI:

- **Add menu item:** `<SITE_URL>/admin/structure/menu/manage/<menu-name>/add`
- **Edit existing items:** `<SITE_URL>/admin/structure/menu/manage/<menu-name>`
- **Reorder items:** Drag and drop on the menu admin page, then save

Menu names for admin URLs: `main`, `footer`, `account`.

**Menu item fields:**

| Field | Description |
| --- | --- |
| Menu link title | Display text for the menu link |
| Link | Target URL (`/path` for internal, full URL for external) |
| Weight | Sort order (lower = higher in menu), or drag to reorder |
| Enabled | Whether the item is visible (checkbox) |
| Parent link | Parent menu item for nested menus (dropdown) |

## Common Pitfalls

1. **Wrong media ID type:** Using a file entity's `drupal_internal__fid` instead of the media entity's `drupal_internal__mid` causes "entity not found" or null-reference errors. Always use the media entity's ID for reference fields.

2. **Missing langcode permission:** When creating content, omit the `langcode` field unless you specifically need to set it. The API may reject requests with `langcode` if the user lacks translation permissions.

3. **PATCH limitations:** PATCH requests may not work for all fields. Some fields are read-only or require specific permissions. If updates fail, check field-level permissions and try omitting problematic fields.

4. **Formatted text needs the wrapper object:** Body and other rich text fields require `{ "value": "<p>...</p>", "format": "full_html" }`. Sending a plain string instead of the wrapper object will cause validation errors.

5. **JSON:API read-only mode:** If all write operations return HTTP 405, the JSON:API module is configured for read-only mode. Enable write operations at `/admin/config/services/jsonapi` by changing the "Allowed operations" setting.

6. **Content-Type header required for writes:** POST and PATCH requests must include `Content-Type: application/vnd.api+json`. Omitting this header will result in 415 Unsupported Media Type errors.

7. **The `data.type` field must match the URL:** When POSTing to `/jsonapi/node/article`, the `data.type` must be `node--article`. A mismatch causes 409 Conflict errors.

8. **PATCH requires `data.id`:** Unlike POST (where the server assigns the UUID), PATCH requests must include the entity's UUID in `data.id`. Omitting it causes 400 Bad Request.

9. **Relationship endpoints vs attribute endpoints:** To update entity references, use the relationship endpoint (`/jsonapi/node/article/{uuid}/relationships/field_image`) or include the relationship in the PATCH body. They are not regular attributes.

10. **Maximum page size is 50:** The JSON:API enforces a maximum `page[limit]` of 50. To retrieve more entities, paginate using `page[offset]` or follow `links.next`.
