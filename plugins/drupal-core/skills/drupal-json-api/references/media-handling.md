# Media Handling Reference

Complete reference for uploading, managing, and referencing media entities via Drupal's JSON:API.

## Media Architecture in Drupal

Drupal uses a two-layer media system:

1. **File entities** (`file--file`): Raw binary files stored on disk or in cloud storage. Each has a `uri` (storage path) and `filemime` (MIME type).
2. **Media entities** (`media--image`, `media--document`, `media--video`, etc.): Content entities that wrap file entities and add metadata (name, alt text, categories, tags).

Content types reference **media entities**, not file entities directly. This means when you want to attach an image to a node, you create or reference a media entity.

## Media vs File Entity IDs (Critical)

This is the most common source of errors when working with media via the API.

| Entity Type | ID Field | How to Find It | Usage |
| --- | --- | --- | --- |
| **File** | `drupal_internal__fid` | In file entity attributes, or in `meta.drupal_internal__target_id` within the media's `field_media_image` relationship | Internal file storage only |
| **Media** | `drupal_internal__mid` | In media entity attributes, or in `meta.drupal_internal__target_id` within a node's media relationship | **Use this for entity reference fields** |

**Rule of thumb:** If you are populating a field on a node or other content entity that references media, always use the media entity's UUID or internal ID, never the file's.

## Uploading Files

### Step 1: Upload the Binary File

Use the file upload endpoint for the specific media bundle and field:

```bash
curl -X POST https://example.com/jsonapi/media/image/field_media_image \
  -H "Content-Type: application/octet-stream" \
  -H "Accept: application/vnd.api+json" \
  -H "Content-Disposition: file; filename=\"photo.jpg\"" \
  --data-binary @photo.jpg
```

**URL pattern:** `/jsonapi/{media_entity_type}/{bundle}/{file_field_name}`

Common upload endpoints:

| Media Type | Upload Endpoint |
| --- | --- |
| Image | `/jsonapi/media/image/field_media_image` |
| Document | `/jsonapi/media/document/field_media_document` |
| Video | `/jsonapi/media/video/field_media_video_file` |

**Important headers:**
- `Content-Type: application/octet-stream` (not `multipart/form-data`)
- `Content-Disposition: file; filename="actual-filename.ext"` (the filename matters for MIME type detection)

### Step 1 Response

The response contains the created file entity:

```json
{
  "data": {
    "type": "file--file",
    "id": "aabbccdd-1234-5678-9012-abcdef123456",
    "attributes": {
      "drupal_internal__fid": 101,
      "filename": "photo.jpg",
      "filemime": "image/jpeg",
      "filesize": 245678,
      "uri": {
        "value": "public://2025-03/photo.jpg",
        "url": "/sites/default/files/2025-03/photo.jpg"
      },
      "status": true
    }
  }
}
```

Save the `data.id` (UUID) from this response for the next step.

### Step 2: Create the Media Entity

Create a media entity that references the uploaded file:

```bash
curl -X POST https://example.com/jsonapi/media/image \
  -H "Content-Type: application/vnd.api+json" \
  -H "Accept: application/vnd.api+json" \
  -d '{
    "data": {
      "type": "media--image",
      "attributes": {
        "name": "Photo description",
        "status": true
      },
      "relationships": {
        "field_media_image": {
          "data": {
            "type": "file--file",
            "id": "aabbccdd-1234-5678-9012-abcdef123456",
            "meta": {
              "alt": "Descriptive alt text for the image",
              "title": "Optional title attribute",
              "width": 1200,
              "height": 800
            }
          }
        }
      }
    }
  }'
```

The `meta.alt` field is typically required for image media. The `meta.width` and `meta.height` are optional but recommended.

### Step 2 Response

```json
{
  "data": {
    "type": "media--image",
    "id": "eeff0011-2233-4455-6677-889900aabbcc",
    "attributes": {
      "drupal_internal__mid": 42,
      "name": "Photo description",
      "status": true
    },
    "relationships": {
      "field_media_image": {
        "data": {
          "type": "file--file",
          "id": "aabbccdd-1234-5678-9012-abcdef123456",
          "meta": {
            "drupal_internal__target_id": 101,
            "alt": "Descriptive alt text for the image",
            "width": 1200,
            "height": 800
          }
        }
      },
      "thumbnail": {
        "data": {
          "type": "file--file",
          "id": "aabbccdd-1234-5678-9012-abcdef123456"
        }
      }
    }
  }
}
```

The media UUID (`data.id`) is what you use when referencing this image from content entities.

## Referencing Media in Content

### Entity Reference Field (relationship)

Most content types use entity reference fields to link to media:

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
          "id": "eeff0011-2233-4455-6677-889900aabbcc"
        }
      }
    }
  }
}
```

### Multi-Value Media Reference

For fields that accept multiple media items:

```json
{
  "relationships": {
    "field_gallery": {
      "data": [
        { "type": "media--image", "id": "media-uuid-1" },
        { "type": "media--image", "id": "media-uuid-2" },
        { "type": "media--image", "id": "media-uuid-3" }
      ]
    }
  }
}
```

## Fetching Media with Includes

To get the full media details (including the file URL) when fetching content, use includes:

```bash
# Include the media entity
curl 'https://example.com/jsonapi/node/article/{uuid}?include=field_image'

# Include the media entity AND its file (to get the actual file URL)
curl 'https://example.com/jsonapi/node/article/{uuid}?include=field_image,field_image.field_media_image'

# Include thumbnail specifically
curl 'https://example.com/jsonapi/node/article/{uuid}?include=field_image,field_image.thumbnail'
```

The file URL is in the included file entity at `attributes.uri.url`.

## Formatted Text Fields

While not strictly media, formatted text fields are often used alongside media and follow a similar pattern of requiring a structured object rather than a plain value.

### Structure

```json
{
  "body": {
    "value": "<p>HTML content with <a href=\"/page\">links</a> and <strong>formatting</strong>.</p>",
    "format": "full_html"
  }
}
```

### Common Text Formats

| Format | Description |
| --- | --- |
| `full_html` | Allows all HTML tags; use for trusted content |
| `basic_html` | Limited HTML tags (p, a, strong, em, ul, ol, li, etc.) |
| `restricted_html` | Very limited HTML; stripped of most tags |
| `plain_text` | No HTML allowed; displayed as-is |

The available formats depend on site configuration. Check `/admin/config/content/formats` for the list of enabled formats and their allowed tags.

### Common Mistakes with Text Fields

**Wrong:** Sending a plain string for a formatted text field.

```json
{
  "body": "This is my content"
}
```

**Right:** Sending the structured object with `value` and `format`.

```json
{
  "body": {
    "value": "<p>This is my content</p>",
    "format": "full_html"
  }
}
```

The API will reject plain strings for formatted text fields with a validation error.

## Updating Media Entities

### Update Media Metadata

```bash
curl -X PATCH https://example.com/jsonapi/media/image/eeff0011-2233-4455-6677-889900aabbcc \
  -H "Content-Type: application/vnd.api+json" \
  -d '{
    "data": {
      "type": "media--image",
      "id": "eeff0011-2233-4455-6677-889900aabbcc",
      "attributes": {
        "name": "Updated image name"
      }
    }
  }'
```

### Replace the File on a Media Entity

Upload a new file (step 1 from above), then update the media entity's file relationship:

```bash
curl -X PATCH https://example.com/jsonapi/media/image/eeff0011-2233-4455-6677-889900aabbcc/relationships/field_media_image \
  -H "Content-Type: application/vnd.api+json" \
  -d '{
    "data": {
      "type": "file--file",
      "id": "new-file-uuid",
      "meta": {
        "alt": "Updated alt text"
      }
    }
  }'
```

## Deleting Media

```bash
# Delete a media entity (does not delete the underlying file)
curl -X DELETE https://example.com/jsonapi/media/image/eeff0011-2233-4455-6677-889900aabbcc

# Delete the file entity separately if needed
curl -X DELETE https://example.com/jsonapi/file/file/aabbccdd-1234-5678-9012-abcdef123456
```

Deleting a media entity does not automatically delete the underlying file entity. Drupal's garbage collection will eventually clean up orphaned files, or you can delete them explicitly.

## Listing and Searching Media

```bash
# List all images
curl 'https://example.com/jsonapi/media/image?sort=-created'

# Search by name
curl 'https://example.com/jsonapi/media/image?filter[name-filter][condition][path]=name&filter[name-filter][condition][operator]=CONTAINS&filter[name-filter][condition][value]=hero'

# List with file URLs included
curl 'https://example.com/jsonapi/media/image?include=field_media_image&sort=-created&page[limit]=10'
```
