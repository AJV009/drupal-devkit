# Project overview

This is a local repository to track and develop the components for an Acquia
Source instance.

Acquia Source is a SaaS CMS using Drupal Canvas for page building. This works by
having React based components (@src/components) that are combined on a page.

The '@src/components/global.css' file contains the global styles for the site.

The site is mobile first and responsive.

# Formatting rules

Do not break long lines into multiple lines for visual formatting. Write each
sentence or logical unit on a single line and let the editor handle word wrap.
This applies to all files: SKILL.md, CLAUDE.md, markdown docs, YAML
descriptions, and code comments.

# Available MCP servers

## Storybook

The storybook MCP server is available to provide links and instructions for the
components in src/components.

When viewing components, you will need to translate the links: localhost:6006 to
https://fg-ai.ddev.site.

The storybook component page will include descriptions of controls, as well as
stories, which give example collections of control input.

When evaluating the rendered version of a component, it is important to view the
isolated view mode, so you are only getting the component, not the storybook UI.
This is particularly required to ensure screen size breakpoints are correctly
rendered. This can be translated from the component URL as follows:

- Url with custom control arguments:
  https://fg-ai.ddev.site/?path=/docs/components-blockquote--docs&args=text:Test
- Find the variation you want to look at (e.g. "dark").
- Isolated url:
  https://fg-ai.ddev.site/index.html?idcomponents-blockquote--dark&args=text:Test&viewMode=story

When using existing assets (e.g. logos), these should be downloaded (for files)
or copied verbatim (for svg). Only SVGs can be directly added to components and
and should only be done for icons or site-wide items such as logos. All other
assets should be part of stories, and should be stored in the storybook assets
folder rather than the component folder.

When creating a new component, you will also need to create:

- Its `component.yml`: Describes the component to Drupal Canvas, including
  dependencies and props. Slots are the spaces for other components to be placed
  dynamically (e.g. @src/components/section/component.yml).
- A component story file: Exposes the story to the storybook UI, including
  controls and examples.
- A page story file: Either create or update an existing page example so we can
  see what the component looks like in context. Some pages match specific pages
  or page types on the source site (e.g. home page) and should be updated in
  with that source page, rather than used to demo other components.

Note, page stories must **only** use components. The only time HTML should be
used is if a component specifically accepts HTML as a prop. Component slots must
only take other components. The full page should be directly embedded into the
story so the "show code" includes the components.

## Playwright

Playwright is for development and data extraction — Storybook navigation, source
site DOM inspection, computed CSS extraction, and bulk content scraping. It runs
headless and is not visible to the user.

Use Playwright for: navigating Storybook UI and viewing rendered components
(wait 1s for JS to render), inspecting the source site's DOM structure, element
hierarchy, and computed CSS, and extracting content/images/URLs from public
pages. Use the snapshot tool for structured DOM descriptions and the screenshot
tool for visual reference. Go beyond visual screenshots — inspect how the source
site is built (grid layouts, flex containers, menu structures).

**Do NOT use Playwright for live site verification or Drupal admin UI.** Use
`claude-in-chrome` MCP for those — the user watches the Chrome browser in real
time to monitor progress. See the migrate-site skill's Browser Tool Policy for
details.

Where relevant, actions can be performed on both the source site and the
rendered components. Examples are clicking on mobile menus to expand them, or
interacting with popups / overlays to dismiss them.

## Source MCP (Acquia Source)

The `source-mcp` server connects to the Acquia Source CMS instance. It provides
access to the Drupal backend for content and configuration management. The URL
is configured in `.mcp.json` and points to the CMS URL (not the public site).

**Authentication required.** The `/mcp` endpoint requires an authenticated
session. It uses the same OAuth 2.0 Client Credentials flow as the Canvas CLI
and content API. If the MCP connection fails with "You must be logged in":

1. Ensure the API client is configured in Acquia Source admin at
   `/admin/config/services/api-clients` (see `acquia-source-setup` skill).
2. The MCP transport should pick up auth automatically if the Drupal site's MCP
   module is configured to use the same OAuth client.
3. If manual auth is needed, obtain a token using the `.env` credentials:
   ```bash
   curl -s -X POST <CMS_URL>/oauth/token \
     -d "grant_type=client_credentials&client_id=<CLIENT_ID>&client_secret=<CLIENT_SECRET>&scope=canvas:js_component canvas:asset_library member"
   ```
   Then add the token as a header in `.mcp.json`:
   ```json
   "source-mcp": {
     "type": "http",
     "url": "https://<CMS_URL>/mcp",
     "headers": {
       "Authorization": "Bearer <token>"
     }
   }
   ```
   **Note:** OAuth tokens expire (typically after 300s). If the MCP connection
   drops, regenerate the token and update the header.

# Content API Types

The JSON:API exposes the following types for content management:

- `page` — Canvas pages with components
- `node--article` — Article content type
- `node--person` — Person content type
- `media--image` — Image media entities
- `media--video`, `media--document` — Other media types
- `menu_items--main` — Main navigation menu items (read-only: list only)
- `menu_items--footer` — Footer menu items (read-only: list only)
- `menu_items--social-media` — Social media link items (read-only: list only)
- `taxonomy_term--categories`, `taxonomy_term--tags` — Taxonomy

Menu items are **read-only** via JSON:API (can list but not create/update/delete
— returns 405). Manage menus through the Drupal admin UI at
`/admin/structure/menu/manage/<menu-name>` using browser automation
(`claude-in-chrome` MCP). See the content-management skill for details.

The full OpenAPI specification for the JSON:API is at
`.claude/skills/content-management/jsonapi_specification.json`. Read it for
exact endpoint schemas, field definitions, and relationship structures.

**Acquia Source admin paths differ from standard Drupal.** Key differences:

- Site name, logo, favicon: `/admin/config/system/site-settings` (NOT
  `/admin/config/system/site-information` — access denied)
- URL aliases: `/admin/config/search/path`
- Redirects: `/admin/config/search/redirect`
- No `/admin/appearance/settings` access — logo/favicon are on the site-settings
  page

# Canvas Editor

Acquia Source provides web-based editors for inspecting deployed components and
composing pages:

- **Component Code Editor** — `<CMS_URL>/canvas/code-editor/component/<name>`:
  View the deployed component source code, props, slots, and a live preview. Use
  this to verify that uploaded components match your local source and have
  correct prop/slot definitions.
- **Page Editor** — `<CMS_URL>/canvas/editor/canvas_page/<id>`: Visual page
  composition tool showing the component tree. Use this to inspect how
  components are nested, debug slot/parent relationships, and verify page
  structure.

The CMS URL is configured in `.env` as `CANVAS_SITE_URL`.

# Acquia Source Documentation

Official Acquia Source documentation is available via the
`acquia-source-docs-explorer` skill. This skill searches a local sitemap of 135+
documentation pages and fetches their full content from docs.acquia.com on
demand.

**Use it whenever you need to understand how Acquia Source works:**

```
/acquia-source-docs-explorer <query>
```

Examples:

- `/acquia-source-docs-explorer known issues and limitations`
- `/acquia-source-docs-explorer menu management and configuration`
- `/acquia-source-docs-explorer creating custom components`
- `/acquia-source-docs-explorer site settings configuration`

**Critical platform constraints** (from known issues):

- **Never remove components via the Component Library UI** — triggers an error
  that can break the site. Use the Code component panel instead.
- Tailwind directives work in `global.css` only, not in component-specific CSS.
- Tailwind square bracket notation does not work with `@apply` — use `@theme`
  variables.

To update the sitemap when new docs are published:

```bash
.claude/skills/acquia-source-docs-explorer/scripts/sitemap_update.sh
```

# Canvas Documentation

- Official docs: `https://project.pages.drupalcode.org/canvas/`
- Code Components:
  `https://project.pages.drupalcode.org/canvas/code-components/`
- Packages (FormattedText, cn, CVA, SWR):
  `https://project.pages.drupalcode.org/canvas/code-components/packages/`
- Data Fetching (getPageData, getSiteData, JsonApiClient):
  `https://project.pages.drupalcode.org/canvas/code-components/data-fetching/`
- Git repo: `https://git.drupalcode.org/project/canvas`
- Drupal.org project: `https://www.drupal.org/project/canvas`

# Canvas-Starter Reference

Canonical Canvas component development reference skills from the official
canvas-starter are available at `.claude/reference/canvas-starter/` (installed
via `canvas-cc-starter` package, symlinked on `npm install`).

# Available Commands

In addition to the MCP servers, you also have the following commands available:

- `npm code:check`: Run code checks on the components.
- `npm code:fix`: Run code checks on the components and attempt to fix them.
- `canvas:validate`: Run validation checks for Drupal Canvas against the
  components. Can take `-c <component>` to narrow the scope to a specific
  component. Additional options must come after a `--`.
- `canvas:upload`: Upload the components to Acquia Source. Can take
  `-c <component>` to narrow the scope to a specific component. Additional
  options must come after a `--`.
- `canvas:ssr-test`: Run SSR smoke test — renders every component server-side
  with no props to catch runtime crashes before uploading.
- `canvas:preflight`: Run full pre-upload validation pipeline (code:check →
  canvas:validate → canvas:ssr-test). Always run before `canvas:upload`.
- `content`: Interact with content in the Drupal site.
