---
name: content-management
description: 'Managing content in Acquia Source via JSON:API. Covers listing, fetching, creating, updating, and deleting pages and content entities using npm run content commands. Includes page component structure (uuid, component_id, inputs, parent_uuid, slot), image uploading and media target_id handling, formatted HTML text fields, UUID generation, input format reference mapping component.yml prop types to JSON formats, menu item listing (menu_items--main, menu_items--footer, menu_items--social-media are read-only via API — must use admin UI for create/update/delete), page path alias management, and common pitfalls like wrong media IDs, link props as objects instead of strings, plain strings for HTML fields, target_id as integer instead of string, langcode errors, and JSON:API read-only mode. Use when composing pages, adding components to pages, uploading images, or interacting with the Acquia Source content API.'
---

# Content Management Skill

This skill provides tools for managing content in Acquia Source via JSON:API. Use these commands to list, fetch, update, and create pages and other content entities.

## Available Commands

All commands use a single entrypoint:

```bash
npm run content -- <command> [args...]
```

### List Content

List content items of a specific type:

```bash
npm run content -- list <type>
npm run content -- list --types  # Discover available types
```

### Get Content

Fetch one or more content items and save them locally:

```bash
npm run content -- get <type> <uuid> [<uuid>...]
npm run content -- get <type> <uuid> --include <relationships>
```

Examples:

```bash
npm run content -- get page abc-123-def
npm run content -- get page abc-123 def-456 ghi-789
npm run content -- get media--image uuid1 uuid2 uuid3
npm run content -- get page abc-123-def --include image,owner
```

Saves content to `content/<type>/<uuid>.json`. For `media--image`, automatically includes the file relationship and displays the thumbnail URL and `target_id`.

### Create Content

Create a new content item from a local file:

```bash
npm run content -- create <file-path>
```

After creation, the temporary file is removed and the full entity is fetched and saved with the UUID returned by the API.

### Update Content

Push changes from a local JSON file back to the API:

```bash
npm run content -- update <file-path>
```

The file must contain valid JSON:API data with `data.type` and `data.id` fields.

### Delete Content

Delete one or more content items:

```bash
npm run content -- delete <type> <uuid> [<uuid>...]
```

Examples:

```bash
npm run content -- delete page abc-123-def
npm run content -- delete media--image uuid1 uuid2 uuid3
```

Also removes the local JSON file if it exists.

### Upload Image

Upload an image and create a media entity:

```bash
npm run content -- upload <image-path> [alt-text]
```

Example:

```bash
npm run content -- upload src/stories/assets/photo.jpg "Photo description"
```

Output includes:

- Media UUID
- File path
- Thumbnail URL
- `target_id` for use in components

### Generate UUID

Generate random UUIDs for new components:

```bash
npm run content -- uuid        # Generate 1 UUID
npm run content -- uuid 5      # Generate 5 UUIDs
```

## Local File Storage

Content is stored in the `/content` directory (gitignored):

```
content/
  page/
    abc-123-def-456.json
  media--image/
    img-123-456.json
```

## Page Structure

Pages in Acquia Source contain these key attributes:

- `title` - Page title
- `status` - Published status (true/false)
- `path` - URL path configuration
- `components` - Array of canvas components
- `metatags` - SEO metadata
- `include_in_search` - Whether to index for search

### Canvas Component Structure

Components are stored in `data.attributes.components` as a flat array. Nesting is defined via `parent_uuid` and `slot` fields:

```json
{
  "data": {
    "type": "page",
    "attributes": {
      "title": "My Page",
      "status": true,
      "components": [
        {
          "uuid": "comp-001",
          "component_id": "js.section",
          "inputs": { "width": "Normal" },
          "parent_uuid": null,
          "slot": null
        },
        {
          "uuid": "comp-002",
          "component_id": "js.heading",
          "inputs": { "text": "Title", "level": "h2" },
          "parent_uuid": "comp-001",
          "slot": "content"
        }
      ]
    }
  }
}
```

Note: `inputs` are automatically parsed to objects when fetched and stringified when sent back to the API.

### Component Fields

| Field               | Description                                                |
| ------------------- | ---------------------------------------------------------- |
| `uuid`              | Unique identifier for this component instance              |
| `component_id`      | Component type (e.g., `js.heading`, `js.card`)             |
| `component_version` | Version hash of the component definition                   |
| `inputs`            | Object containing prop values                              |
| `parent_uuid`       | UUID of parent component (null for root-level)             |
| `slot`              | Slot name in parent (null for root-level, e.g., "content") |

## Media Image Handling

### Uploading Images

Images must be uploaded to the media library before referencing in components:

```bash
npm run content -- upload image.jpg "Alt text"
```

Output:

```
Uploading: image.jpg
Uploaded: image.jpg
  UUID: 98eabd02-c52c-493b-8ca9-cb9d0fe70ceb
  File: /var/www/html/pages/media--image/98eabd02-...json
  Thumbnail: https://...
  target_id: 31
```

### Media vs File Entity IDs (Critical)

When working with images, there are two different internal IDs:

| Entity Type | ID Location                                   | Usage                      |
| ----------- | --------------------------------------------- | -------------------------- |
| **File**    | `drupal_internal__target_id` in relationships | Internal file reference    |
| **Media**   | `resourceVersion=id%3AXX` in self link URL    | **Use this in components** |

The `target_id` shown in command output is the correct media internal ID.

### Referencing Images in Components

Components that accept images (like `js.card`) use a `target_id` reference:

```json
{
  "component_id": "js.card",
  "inputs": {
    "heading": "My Card",
    "image": { "target_id": "31" },
    "text": { "value": "<p>Content</p>", "format": "canvas_html_block" }
  }
}
```

**Important:** The `target_id` must be the **media entity's internal ID**, not the file's internal ID.

### Text Fields with HTML

Rich text fields use a specific format:

```json
{
  "text": {
    "value": "<p>HTML content with <a href=\"/page\">links</a>.</p>",
    "format": "canvas_html_block"
  }
}
```

## Workflow Examples

### Download and Edit a Page

```bash
npm run content -- list page
npm run content -- get page abc-123-def
# Edit content/page/abc-123-def.json
npm run content -- update content/page/abc-123-def.json
```

### Create a Page with Images

1. Upload images:

   ```bash
   npm run content -- upload image1.jpg "Description"
   # Note target_id: 31
   ```

2. Generate UUIDs:

   ```bash
   npm run content -- uuid 3
   ```

3. Create page JSON at `content/page/new-my-page.json`:

   ```json
   {
     "data": {
       "type": "page",
       "attributes": {
         "title": "My Page",
         "status": true,
         "components": [
           {
             "uuid": "generated-uuid",
             "component_id": "js.card",
             "inputs": {
               "heading": "Card",
               "image": { "target_id": "31" }
             },
             "parent_uuid": null,
             "slot": null
           }
         ],
         "path": { "alias": "/my-page" },
         "include_in_search": true
       }
     }
   }
   ```

4. Create the page:

   ```bash
   npm run content -- create content/page/new-my-page.json
   ```

## Input Format Reference

**Always read `component.yml` before composing inputs.** The prop type in `component.yml` determines how the value must be formatted in the page JSON.

| component.yml Type | JSON Input Format | Example |
| --- | --- | --- |
| `type: string` (plain) | Plain string | `"heading": "Hello"` |
| `type: string` with `contentMediaType: text/html` | Formatted text object | `"text": { "value": "<p>Hello</p>", "format": "canvas_html_block" }` |
| `type: string` with `format: uri-reference` | Plain string (path or URL) | `"link": "/about"` |
| `type: object` with `$ref: .../image` | target_id object (string) | `"image": { "target_id": "31" }` |
| `type: string` with `enum` | Exact enum value string | `"layout": "Left aligned"` |
| `type: boolean` | Boolean | `"visible": true` |
| `type: integer` / `type: number` | Number | `"count": 3` |

## Common Pitfalls

1. **Wrong ID type**: Using file's `drupal_internal__target_id` instead of media's internal ID causes "image.src NULL value found" errors.

2. **Missing langcode permission**: When creating pages, omit the `langcode` field as the API may reject it with permission errors.

3. **Patching limitations**: PATCH requests may not work for all fields. Create a new page with a different alias if updates fail.

4. **Link props are plain strings, not objects**: Link/URL props (`format: uri-reference`) must be plain strings like `"/about"`. Do NOT use Drupal's link field format `{ "uri": "/about", "options": [] }` — that is for Drupal entity fields, not Canvas component inputs.

   ```json
   // ✅ Correct
   "link": "/services"

   // ❌ Wrong — will cause errors
   "link": { "uri": "/services", "options": [] }
   ```

5. **Formatted text fields need the wrapper object**: Any prop with `contentMediaType: text/html` in `component.yml` must use the formatted text object, not a plain string. Omitting the wrapper may cause rendering failures or empty output.

   ```json
   // ✅ Correct
   "text": { "value": "<p>Content here</p>", "format": "canvas_html_block" }

   // ❌ Wrong — plain string for an HTML field
   "text": "Content here"
   ```

6. **target_id must be a string**: Image references use `"target_id": "31"` (a string), not `"target_id": 31` (an integer). Using an integer may cause type errors.

7. **JSON:API read-only mode**: If all write operations return HTTP 405, the JSON:API is configured for read-only. Enable write operations at `/admin/config/services/jsonapi` on the Acquia Source admin panel.

## Menu Management

Acquia Source exposes menu items via JSON:API, but **the endpoints are read-only**. Menu items can be listed but not created, updated, or deleted via JSON:API (POST/PATCH/DELETE return 405 Method Not Allowed, individual GET returns 404).

Available menu types for listing:

- `menu_items--main` — Main navigation menu
- `menu_items--footer` — Footer links
- `menu_items--social-media` — Social media links

### Listing Menu Items (read-only)

```bash
npm run content -- list menu_items--main
npm run content -- list menu_items--footer
npm run content -- list menu_items--social-media
```

### Creating and Editing Menu Items (admin UI only)

Menu items must be managed through the Drupal admin UI, not the JSON:API. Use browser automation (`claude-in-chrome` MCP) to navigate the admin pages:

- **Add menu item:** `<CMS_URL>/admin/structure/menu/manage/<menu-name>/add` (e.g., `.../manage/main/add`)
- **Edit existing items:** `<CMS_URL>/admin/structure/menu/manage/<menu-name>` then click edit on individual items
- **Reorder items:** Drag and drop on the menu admin page, then save

Menu names for admin URLs: `main`, `footer`, `social-media`.

**Menu item fields in the admin UI:**

| Field | Description |
| --- | --- |
| Menu link title | Display text for the menu link |
| Link | Target URL (`/path` for internal, full URL for external) |
| Weight | Sort order (lower = higher in menu), or drag to reorder |
| Enabled | Whether the item is visible (checkbox) |
| Parent link | Parent menu item for nested menus (dropdown) |

## Page Path Management

When creating pages, set the path alias to control the URL:

```json
{
  "data": {
    "type": "page",
    "attributes": {
      "title": "About",
      "path": { "alias": "/about" },
      "status": true,
      "components": []
    }
  }
}
```

**Important:** Ensure page paths match the source site exactly. Use `/about` not `/about-us`. Verify aliases at `<CMS_URL>/admin/config/search/path`. Note: Acquia Source does NOT expose `/admin/config/system/site-information` — use `/admin/config/system/site-settings` for site name, logo, and favicon.

## Verifying Content in Canvas Editor

After creating or updating a page, verify the result in the Canvas Page Editor at `<CMS_URL>/canvas/editor/canvas_page/<id>`. This visual editor shows the component tree and allows you to inspect how components are nested and composed. It is especially useful for debugging slot/parent relationships and verifying that all sections appear in the correct order.

For individual component issues, use the Component Code Editor at `<CMS_URL>/canvas/code-editor/component/<name>` to verify the deployed component's props, slots, and live preview.

## Acquia Source Documentation

When working with the Acquia Source content API, consult the official documentation for platform-specific behavior, API capabilities, and known limitations. Use the `acquia-source-docs-explorer` skill:

```
/acquia-source-docs-explorer JSON API content management menus
```

Key docs to consult:
- **`enabling-api`** and **`using-api`** — API setup and usage patterns
- **`jsonapi-query-builder`** — query syntax and filtering
- **`menus`** and **`adding-links-menu`** — menu management (read-only via API, admin UI required for writes)
- **`content-workflows`** — publishing states and revision behavior
- **`fields`** and **`field-types`** — available field types and their API representations

Always check the docs before assuming standard Drupal JSON:API behavior — Acquia Source has platform-specific differences.

## JSON:API OpenAPI Specification

This skill directory contains the site's JSON:API reference:

- **`jsonapi_summary.md`** — Start here. A readable summary of all resource types, their attributes, relationships, and endpoints. Includes a "Not Available via API" section documenting what requires admin UI (menus, site settings, URL aliases).
- **`jsonapi_specification.json`** — The full OpenAPI (Swagger) spec with complete request/response schemas, field definitions, and query parameters. Consult this when you need the exact API shape for a resource type.

The spec covers: `page`, `file--file`, `media--image`, `media--video`, `media--document`, `node--article`, `node--person`, `taxonomy_term--categories`, `taxonomy_term--tags`, and Acquia DAM media types. URLs in the spec use `<ID>.cms.acquia.site` as a generic placeholder — substitute with your actual `CANVAS_SITE_URL` from `.env`.

## Environment Variables

Required in `.env`:

- `CANVAS_SITE_URL` - Base URL of Acquia Source site
- `CANVAS_JSONAPI_PREFIX` - API prefix (default: "api")
- `CANVAS_CLIENT_ID` - OAuth client ID
- `CANVAS_CLIENT_SECRET` - OAuth client secret
