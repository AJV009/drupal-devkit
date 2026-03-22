---
name: drupal-views
description: 'Manage Drupal Views -- creating views, configuring displays, adding fields/filters/sorts/relationships/contextual filters, setting formats, page/block settings, and more.'
metadata:
  source: drupal.org/project/ai_agents_experimental_collection
  source_license: GPL-2.0-or-later
  original_agent: views_manager
---

# Drupal Views Management

Views is Drupal's query builder and display system for creating dynamic listings of content, users, taxonomy terms, and more.

## Key Concepts

- **View**: A saved configuration entity that defines a database query and how to display results. Identified by a machine name (id).
- **Base Table**: The primary data source -- `node_field_data` for content, `users_field_data` for users, `taxonomy_term_field_data` for taxonomy terms, `media_field_data` for media, `comment_field_data` for comments.
- **Display**: A view can have multiple displays, each showing the same base query differently. Types:
  - **default**: The master display all others inherit from. Always exists. Cannot be deleted.
  - **page**: Creates a page at a URL path. Can have menu settings.
  - **block**: Creates a placeable block. Can have block category and override settings.
  - **feed**: Creates an RSS/Atom feed at a URL path.
  - **attachment**: Attaches before/after another display.
- **Display Inheritance**: Non-default displays inherit all settings from the default display. Only settings explicitly overridden on a display are stored on that display. To change all displays at once, modify the default display.

## Handler Types

Handlers are the building blocks of a view's query and output:

- **field**: What columns/data to show. Each field has a formatter, label, and options.
- **filter**: WHERE clauses that limit results. Can be exposed to let users filter interactively.
- **sort**: ORDER BY clauses. Can be exposed to let users choose sort order.
- **relationship**: JOINs to related data (e.g., node author, referenced entities).
- **argument**: Contextual filters from the URL path (e.g., `/articles/%` where `%` is a taxonomy term ID).
- **header**: Content shown above results (custom text, result summary, etc.).
- **footer**: Content shown below results.
- **empty**: Content shown when there are no results.

All handler operations use the same tools (AddHandler, UpdateHandler, RemoveHandler, ListHandlers) with a `handler_type` parameter.

## Filter Value Format

Different filter types require different value formats. The tools auto-normalize, but for reference:

- **Boolean filters** (status, promote, sticky): use a simple string value `{"value": "1"}` for true, `{"value": "0"}` for false
- **Bundle/type filters**: use an associative array `{"value": {"article": "article"}}`. Multiple: `{"value": {"article": "article", "page": "page"}}`
- **Language filters**: use an associative array `{"value": {"en": "en"}}`
- **String/date/numeric filters**: use a simple string value `{"value": "some text"}`

The tools automatically convert between formats when needed, so either format will work.

## Using GetViewsData

Before adding handlers, use GetViewsData to discover available table+field combinations:

- Search "title" to find title fields across tables
- Search "created" for creation date fields
- Search "status" for published/active status fields
- Filter by table (e.g., `table="node_field_data"`) for fields on a specific entity type

The result tells you what `table` and `field` values to use in AddHandler.

## Style/Format System

Each display has a style plugin (how to arrange items) and a row plugin (what each item looks like):

**Style plugins** (set via SetDisplayFormat):

- `default` -- Unformatted list (each row in a div)
- `table` -- HTML table with sortable columns. Options: columns, info (column settings), default sort, sticky headers
- `grid` -- CSS grid layout. Options: columns count, alignment
- `grid_responsive` -- Responsive CSS grid
- `html_list` -- HTML ul/ol list. Options: type (ul/ol), class

**Row plugins**:

- `fields` -- Render individual fields (most common with table/grid/list styles)
- `entity:node` -- Render full node using a view mode (teaser, full, etc.)
- `entity:user`, `entity:taxonomy_term`, etc. -- Entity rendering for other types

## Available Operations

| # | Tool | Operation | Description |
|---|------|-----------|-------------|
| 1 | ListViews | Read | Lists all views with their id, label, base_table, status, and display count |
| 2 | GetView | Read | Gets full details of a view including all displays with their types, titles, and key settings overview |
| 3 | CreateView | Write | Creates a new view with the given id, label, description, and base_table. Automatically creates a default display |
| 4 | DeleteView | Write | Deletes a view by its machine name. Permanently removes the view and all its displays |
| 5 | GetDisplay | Read | Gets full details of a specific display including all settings, handlers, style/row plugins, access, pager, and page/block settings |
| 6 | AddDisplay | Write | Adds a new display (page, block, feed, attachment, etc.) to a view. Returns the generated display_id |
| 7 | DeleteDisplay | Write | Deletes a display from a view. Cannot delete the "default" display |
| 8 | UpdateDisplaySettings | Write | Updates display-level options via a JSON settings object. Supports: title, css_class, use_ajax, group_by, use_more, access, pager, cache, exposed_form, and more |
| 9 | SetDisplayFormat | Write | Sets the style (format) and row plugins for a display. Style types: table, default, grid, grid_responsive, html_list. Row types: fields, entity:node, entity:user, etc. |
| 10 | UpdatePageBlockSettings | Write | Updates display-type-specific settings. For pages: path, menu, tab_options. For blocks: block_description, block_category, allow |
| 11 | ListHandlers | Read | Lists all handlers of a given type (field, filter, sort, relationship, argument, header, footer, empty) for a specific display |
| 12 | AddHandler | Write | Adds a handler (field, filter, sort, relationship, argument, header, footer, or empty) to a view display |
| 13 | UpdateHandler | Write | Updates an existing handler configuration by merging provided options into the existing config |
| 14 | RemoveHandler | Write | Removes a handler (field, filter, sort, relationship, argument, header, footer, or empty) from a view display |
| 15 | GetViewsData | Read | Searches available tables and fields from the Views data cache. Returns matching table+field combos with handler types and help text |

## Common Workflows

### Create a content listing page

1. CreateView with base_table `node_field_data`
2. AddDisplay with display_plugin `page`
3. UpdatePageBlockSettings to set the path
4. Add fields: title, created, author (use AddHandler with handler_type `field`)
5. Add filter for published status (handler_type `filter`, table `node_field_data`, field `status`, options `{"value": "1"}`)
6. Add filter for content type (handler_type `filter`, table `node_field_data`, field `type`, options `{"value": {"article": "article"}}`)
7. Add sort by created date (handler_type `sort`, options `{"order": "DESC"}`)
8. Optionally set format to table via SetDisplayFormat

### Add exposed filters

1. AddHandler for a filter with `{"exposed": true, "expose": {"label": "Content type", "identifier": "type"}, "value": {"article": "article"}}`
2. Or UpdateHandler on existing filter to add exposed settings
3. Configure exposed form settings via UpdateDisplaySettings with `{"exposed_form": {"type": "basic", "options": {"submit_button": "Apply", "reset_button": true}}}`

### Add a block display

1. AddDisplay with display_plugin `block`
2. UpdatePageBlockSettings with block_description and block_category
3. Override settings as needed (fields, pager, etc.)

### Configure pager

- Full pager: UpdateDisplaySettings with `{"pager": {"type": "full", "options": {"items_per_page": 25, "offset": 0}}}`
- Mini pager: `{"pager": {"type": "mini", "options": {"items_per_page": 10}}}`
- Show all: `{"pager": {"type": "none", "options": {}}}`
- Fixed number: `{"pager": {"type": "some", "options": {"items_per_page": 5}}}`

### Configure access

- Permission-based: UpdateDisplaySettings with `{"access": {"type": "perm", "options": {"perm": "access content"}}}`
- Role-based: `{"access": {"type": "role", "options": {"role": {"authenticated": "authenticated"}}}}`
- Unrestricted: `{"access": {"type": "none", "options": {}}}`

### Add header/footer/empty text

- AddHandler with handler_type `header` (or `footer`/`empty`), table `views`, field `area_text_custom`, options `{"content": "My custom header text", "tokenize": false}`
- For result summary: table `views`, field `result`, options `{"content": "Displaying @start - @end of @total"}`

### Contextual filters (arguments)

- AddHandler with handler_type `argument`, appropriate table/field
- Options: `{"default_action": "default", "default_argument_type": "fixed", "default_argument_options": {"argument": "1"}}`
- Or from URL: `{"default_action": "default", "default_argument_type": "raw", "default_argument_options": {"index": 0}}`
- With validation: `{"specify_validation": true, "validate": {"type": "entity:node", "fail": "not found"}}`

### Relationships

- AddHandler with handler_type `relationship`, e.g., table `node_field_data`, field `uid` for author
- Options: `{"admin_label": "Content author", "required": true}`
- Once added, fields from the related table become available

## Display Settings Reference

UpdateDisplaySettings accepts any display option as a key. Common ones:

- `title`: The view title shown to users
- `css_class`: CSS classes on the view wrapper
- `use_ajax`: true/false -- AJAX-enable the view
- `group_by`: true/false -- Enable aggregation (GROUP BY)
- `use_more`: true/false -- Show a "more" link
- `use_more_always`: true/false -- Show "more" even with fewer results
- `use_more_text`: Text for the more link
- `exposed_block`: true/false -- Put exposed form in a block
- `link_display`, `link_url`: Where "more" links point

## Best Practices

- Always use GetView or GetDisplay first to understand the current configuration before making changes.
- Use GetViewsData to discover valid table+field combinations before adding handlers.
- Modify the "default" display for settings that should apply to all displays.
- Override on specific displays only what differs from the default.
- When creating a content view, always add a status filter for published content.
- Use table format when displaying multiple fields in a structured way.
- Use entity row plugin (e.g., `entity:node` with view_mode `teaser`) for rich content displays.
- Set appropriate access controls on every view.
- Confirm deletions before removing views or displays.

## Example Workflows

### Viewing Configuration

- "List all views on the site"
- "Show me the details of the 'content' view"
- "What displays does the 'frontpage' view have?"
- "Show me the handlers on the content view's page display"

### Creating Views

- "Create a new view called 'blog' for listing article content"
- "Create a user directory view based on the users table"
- "Set up a taxonomy term listing view"

### Managing Displays

- "Add a page display to the blog view at /blog"
- "Add a block display to the recent articles view"
- "Delete the feed display from the blog view"
- "Configure the page display with a menu tab"

### Adding Fields and Filters

- "Add the title, body summary, and created date fields to the blog view"
- "Add an exposed filter for content type on the content view"
- "Add a published status filter to only show published content"
- "Add a sort by created date descending"

### Configuring Display Settings

- "Set the blog view to show 10 items per page with a full pager"
- "Change the access on the blog view to require 'access content' permission"
- "Set the style to a table format with sortable columns"
- "Set the row style to 'Content' with the teaser view mode"

### Handler Management

- "Add a relationship to the author field on the blog view"
- "Add a contextual filter for content type"
- "Update the title field label to 'Article Title'"
- "Remove the author field from the blog view"

### Data Discovery

- "Search for available Views data related to taxonomy"
- "What fields are available on the node_field_data table?"

### Complete Setup

- "Create a blog listing page at /blog showing articles with title, image, summary, author, and date, sorted by newest first with a pager"
- "Build a staff directory view as a table with name, email, department, and photo, with an exposed filter for department"
