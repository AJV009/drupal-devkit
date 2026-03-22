---
name: canvas-docs-explorer
description: 'Search and fetch Canvas and Drupal CMS documentation pages. Takes a query describing what you need to know (e.g., "code components", "page regions", "known issues", "data fetching") and returns the full content of matching documentation pages. Invoke with /canvas-docs-explorer <query>. Use this whenever you need to understand how Canvas or Drupal CMS works, verify platform behavior, check for limitations, or find configuration options.'
compatibility: Requires internet access to fetch documentation
---

# Canvas & Drupal CMS Documentation Explorer

Fetch and return official Canvas and Drupal CMS documentation relevant to a query. This skill searches a curated URL list, identifies the most relevant pages, fetches their full content, and returns it for the calling agent to use.

## Arguments

- `$1` — **Query** (required). A natural language description of what you need to know. Examples:
  - `"known issues and limitations"`
  - `"code components props slots"`
  - `"data fetching SWR JsonApiClient"`
  - `"page regions configuration"`
  - `"creating custom components"`
  - `"packages FormattedText cn"`

## Execution

You are a fast research agent. Your job is to find and fetch documentation, not to analyze or act on it. Return the raw content so the calling agent can use it.

### Step 1: Match URLs to the query

From the URL catalog below, identify **all pages relevant** to the query. Match by:

- URL path segments (e.g., query "data fetching" matches the data-fetching URL)
- Semantic relevance (e.g., query "component creation" matches code-components, packages, and getting-started)
- Always include the "Known Issues" section content (inline below) if the query relates to components, Tailwind, Canvas, or troubleshooting

Be generous with matching — it's better to fetch an extra page than miss a relevant one.

### Step 2: Fetch matched pages

For each matched URL, use `WebFetch` to retrieve the page content. Fetch pages in parallel where possible for speed.

Use this prompt for each fetch:
> "Extract the COMPLETE content of this page. Return all text, code examples, tables, steps, warnings, and notes. Do not summarize — return everything."

### Step 3: Return results

Return all fetched content organized by page, with clear headers:

```
## <Page Title> — <URL>

<full page content>

---

## <Next Page Title> — <URL>

<full page content>
```

If a page fails to load (404, 503, timeout), note the failure and continue with remaining pages.

## URL Catalog

### Canvas Official Documentation

| Topic | URL |
|-------|-----|
| Canvas Overview | `https://project.pages.drupalcode.org/canvas/` |
| Code Components | `https://project.pages.drupalcode.org/canvas/code-components/` |
| Getting Started | `https://project.pages.drupalcode.org/canvas/code-components/getting-started/` |
| Component Definition | `https://project.pages.drupalcode.org/canvas/code-components/definition/` |
| Component Props | `https://project.pages.drupalcode.org/canvas/code-components/props/` |
| Component Slots | `https://project.pages.drupalcode.org/canvas/code-components/slots/` |
| Packages (FormattedText, cn, CVA, SWR) | `https://project.pages.drupalcode.org/canvas/code-components/packages/` |
| Data Fetching (getPageData, getSiteData, JsonApiClient) | `https://project.pages.drupalcode.org/canvas/code-components/data-fetching/` |
| Styling | `https://project.pages.drupalcode.org/canvas/code-components/styling/` |
| Upload & Deploy | `https://project.pages.drupalcode.org/canvas/code-components/upload/` |
| Canvas CLI | `https://project.pages.drupalcode.org/canvas/code-components/cli/` |
| Page Regions | `https://project.pages.drupalcode.org/canvas/page-regions/` |
| Known Issues | `https://project.pages.drupalcode.org/canvas/known-issues/` |

### Drupal CMS Documentation

| Topic | URL |
|-------|-----|
| Drupal CMS Overview | `https://new.drupal.org/docs/drupal-cms` |
| Getting Started with Drupal CMS | `https://new.drupal.org/docs/drupal-cms/getting-started` |

### Drupal Core Reference (for JSON:API, menus, etc.)

| Topic | URL |
|-------|-----|
| JSON:API Module | `https://www.drupal.org/docs/core-modules-and-themes/core-modules/jsonapi-module` |
| Menu System | `https://www.drupal.org/docs/drupal-apis/menu-api` |

## Critical Known Issues (Inline Reference)

These are known issues that agents should be aware of WITHOUT needing to fetch the docs page:

1. **Never remove components via the Component Library UI** — triggers an error that can break the site. Use the Code component panel instead.
2. **Tailwind directives** (`@apply`, `@layer`, etc.) work in `global.css` only — NOT in component-specific CSS files.
3. **Tailwind square bracket notation** does not work with `@apply`. Use `@theme` variables instead.
4. **Canvas page regions** default to `status: false` on fresh Drupal CMS installs. Header/footer won't render until enabled via `ddev drush config:set canvas.page_region.mercury.header status true -y`.
5. **JSON:API read-only mode** — standard Drupal CMS defaults to read-only. Enable writes with `ddev drush config:set jsonapi.settings read_only false -y`.
6. **Media image field name** — Standard Drupal uses `field_media_image`, not `media_image`. The content scripts handle both via fallback logic.
7. **Component JS crashes** — An unguarded null access in a component will crash the page renderer. Always guard optional props: `image?.src`, `const { src } = image || {}`.
