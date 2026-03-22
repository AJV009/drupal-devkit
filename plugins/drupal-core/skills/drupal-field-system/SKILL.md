---
name: drupal-field-system
description: 'Manage fields across all fieldable entity types, including field CRUD, form display widgets, view display formatters, and display mode configuration.'
metadata:
  source: drupal.org/project/ai_agents_experimental_collection
  source_license: GPL-2.0-or-later
  original_agent: field_manager
---

# Drupal Field System

This skill covers managing fields for a Drupal site. It applies to all fieldable entity types (node, taxonomy_term, media, block_content, user, paragraph, etc.).

## Capabilities

### Discovery
- List all fieldable entity types and their bundles
- List all available field types with their default widgets and formatters
- List available widgets for a specific field type
- List available formatters for a specific field type
- List available view modes and form modes for an entity type

### Field CRUD
- List all configurable fields on any entity type bundle
- Get full details of a field including storage and field settings
- Add fields to any fieldable entity type bundle with full settings support
- Update field properties (label, required, description, field settings)
- Remove fields from entity type bundles

### Custom Field Support
- Add Custom Fields (from the custom_field module) with structured column definitions
- Each column defines a sub-field with type and configuration

### Form Display (Widgets)
- Get form display configuration showing all widget assignments
- Update form display: change widget type, weight, widget settings, or hide fields

### View Display (Formatters)
- Get view display configuration showing all formatter assignments
- Update view display: change formatter type, label position, weight, formatter settings, or hide fields

## Available Operations

| # | Operation | Description |
|---|-----------|-------------|
| 1 | List Fieldable Entity Types | List all entity types that support fields and their bundles |
| 2 | List Field Types | List all available field types with default widgets and formatters |
| 3 | List Available Widgets | List compatible widgets for a specific field type |
| 4 | List Available Formatters | List compatible formatters for a specific field type |
| 5 | List Fields | List all configurable fields on an entity type bundle |
| 6 | Get Field | Get full details of a specific field (storage settings, field settings) |
| 7 | Add Field | Create a new field on an entity type bundle with full settings support |
| 8 | Get Entity Reference Handlers | Discover available entity reference target types and bundles |
| 9 | Update Field | Update field properties such as label, required, description, or settings |
| 10 | Remove Field | Remove a field from an entity type bundle |
| 11 | Add Custom Field | Add a custom field with structured column definitions (requires custom_field module) |
| 12 | Get Form Display | Get form display configuration showing all widget assignments |
| 13 | Update Form Display | Change widget type, weight, widget settings, or hide fields on a form display |
| 14 | Get View Display | Get view display configuration showing all formatter assignments |
| 15 | Update View Display | Change formatter type, label position, weight, formatter settings, or hide fields on a view display |
| 16 | List View Modes | List available view modes for an entity type |
| 17 | List Form Modes | List available form modes for an entity type |

## Workflow

1. Start by discovering available entity types with **List Fieldable Entity Types**.
2. Use **List Field Types** to find the right field type.
3. Use **List Available Widgets** / **List Available Formatters** to find compatible display plugins.
4. Create fields with **Add Field**, providing `storage_settings` and `field_settings` as JSON strings.
5. Configure form display with **Update Form Display**.
6. Configure view display with **Update View Display**.

## Complex Field Settings Examples

### Entity Reference (IMPORTANT -- requires BOTH storage_settings and field_settings)

For `entity_reference` fields, provide the correct configuration in BOTH settings.

**Reference to node bundles:**
```json
storage_settings: {"target_type": "node"}
field_settings: {"handler": "default:node", "handler_settings": {"target_bundles": {"article": "article"}}}
```

**Reference to taxonomy terms:**
```json
storage_settings: {"target_type": "taxonomy_term"}
field_settings: {"handler": "default:taxonomy_term", "handler_settings": {"target_bundles": {"tags": "tags"}, "auto_create": true}}
```

**Reference to users (no bundles needed):**
```json
storage_settings: {"target_type": "user"}
field_settings: {"handler": "default:user"}
```

**Reference to media:**
```json
storage_settings: {"target_type": "media"}
field_settings: {"handler": "default:media", "handler_settings": {"target_bundles": {"image": "image"}}}
```

Key rules for entity_reference:
- `storage_settings` MUST contain `target_type` (the entity type being referenced)
- `field_settings` MUST contain `handler` in format `default:{target_type}`
- `handler_settings.target_bundles` is a map where keys AND values are the bundle machine name
- If `target_bundles` is omitted or empty, ALL bundles of that type are referenceable
- For taxonomy, add `"auto_create": true` in `handler_settings` to allow creating new terms inline
- Use **Get Entity Reference Handlers** to discover available target types and bundles
- If `field_settings` includes a handler but `storage_settings` is omitted, the tool will auto-detect `target_type` from the handler string

### List String
```json
storage_settings: {"allowed_values": {"red": "Red", "blue": "Blue"}}
```

### Address (with available_countries)
```json
field_settings: {"available_countries": ["US", "CA", "GB"]}
```

### Custom Field (columns)
```json
columns: [{"name": "title", "type": "string", "length": 255}, {"name": "count", "type": "integer", "unsigned": true}]
```

## Important Notes

- Always use `entity_type` + `bundle` to identify where fields live.
- Field names should typically start with `field_`.
- Use cardinality `-1` for unlimited values, `1` for single value.
- JSON strings must be valid JSON for `storage_settings`, `field_settings`, and widget/formatter settings.
- For `entity_reference` fields, ALWAYS use **Get Entity Reference Handlers** first to discover correct target types and bundles.
- The Custom Field tool requires the `custom_field` module to be installed.

## Example Workflows

### Discovery

- "List all fieldable entity types on this site"
- "What field types are available?"
- "What widgets can I use for an entity_reference field?"
- "What formatters are available for image fields?"
- "What view modes does the node entity type have?"

### Field CRUD

- "List all fields on the article content type"
- "Show me the details of the field_tags field on articles"
- "Add a text_long field called field_summary with label 'Summary' to the article content type"
- "Add an entity_reference field called field_related_articles to articles that references other articles"
- "Add a list_string field called field_status to articles with allowed values: draft, review, published"
- "Make the field_summary field required on articles"
- "Update the description of field_tags on articles to 'Select relevant tags'"
- "Remove the field_subtitle field from articles"

### Cross-Entity Type Operations

- "Add a string field called field_subtitle to the tags taxonomy vocabulary"
- "List all fields on the user entity type"
- "Add an image field to the basic block content type"

### Custom Fields

- "Add a custom field called field_dimensions to articles with columns: width (integer), height (integer), unit (string)"

### Form Display

- "Show me the form display for articles"
- "Change the widget for field_body on articles to text_textarea_with_summary"
- "Set the weight of field_tags on articles to 10"
- "Hide the field_subtitle field from the article form"
- "Set the widget settings for field_body with rows: 15"

### View Display

- "Show me the view display for articles"
- "Change the formatter for field_image on articles to image with image_style: large"
- "Set the label position for field_tags on articles to inline"
- "Hide the field_subtitle from the article teaser view mode"
- "Set the weight of field_body on articles to 5 in the default view display"

### Complex Workflows

- "Create a complete product content type with fields for price (decimal), SKU (string), description (text_long), and category (entity_reference to taxonomy). Configure the form display with appropriate widgets and the view display with formatters."
