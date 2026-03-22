# Project overview

This is a Drupal CMS project with Canvas and Mercury theme, used for building and migrating websites with React-based Canvas components.

Canvas components live in `canvas/src/components/` and are combined on pages via the Canvas page builder. The `canvas/src/components/global.css` file contains the global styles for the site.

The site is mobile first and responsive.

**Working directories:** Run all `ddev` commands from the project root. Run all `npm` commands from the `canvas/` subdirectory.

# Formatting rules

Do not break long lines into multiple lines for visual formatting. Write each sentence or logical unit on a single line and let the editor handle word wrap. This applies to all files: SKILL.md, CLAUDE.md, markdown docs, YAML descriptions, and code comments.

# Available MCP servers

## Storybook

The storybook MCP server is available to provide links and instructions for the components in canvas/src/components.

When viewing components, you will need to translate the links: localhost:6006 to the DDEV Storybook URL (check `.ddev/config.yaml` for the project name, then use `https://<project>.ddev.site`).

The storybook component page will include descriptions of controls, as well as stories, which give example collections of control input.

When evaluating the rendered version of a component, it is important to view the isolated view mode, so you are only getting the component, not the storybook UI. This is particularly required to ensure screen size breakpoints are correctly rendered. This can be translated from the component URL as follows:

- Url with custom control arguments:
  https://<project>.ddev.site/?path=/docs/components-blockquote--docs&args=text:Test
- Find the variation you want to look at (e.g. "dark").
- Isolated url:
  https://<project>.ddev.site/index.html?idcomponents-blockquote--dark&args=text:Test&viewMode=story

When using existing assets (e.g. logos), these should be downloaded (for files) or copied verbatim (for svg). Only SVGs can be directly added to components and should only be done for icons or site-wide items such as logos. All other assets should be part of stories, and should be stored in the storybook assets folder rather than the component folder.

When creating a new component, you will also need to create:

- Its `component.yml`: Describes the component to Drupal Canvas, including dependencies and props. Slots are the spaces for other components to be placed dynamically (e.g. canvas/src/components/section/component.yml).
- A component story file: Exposes the story to the storybook UI, including controls and examples.
- A page story file: Either create or update an existing page example so we can see what the component looks like in context. Some pages match specific pages or page types on the source site (e.g. home page) and should be updated with that source page, rather than used to demo other components.

Note, page stories must **only** use components. The only time HTML should be used is if a component specifically accepts HTML as a prop. Component slots must only take other components. The full page should be directly embedded into the story so the "show code" includes the components.

## Playwright

Playwright is for development and data extraction — Storybook navigation, source site DOM inspection, computed CSS extraction, and bulk content scraping. It runs headless and is not visible to the user.

Use Playwright for: navigating Storybook UI and viewing rendered components (wait 1s for JS to render), inspecting the source site's DOM structure, element hierarchy, and computed CSS, and extracting content/images/URLs from public pages. Use the snapshot tool for structured DOM descriptions and the screenshot tool for visual reference. Go beyond visual screenshots — inspect how the source site is built (grid layouts, flex containers, menu structures).

**Do NOT use Playwright for live site verification or Drupal admin UI.** Use `claude-in-chrome` MCP for those — the user watches the Chrome browser in real time to monitor progress. See the migrate-site skill's Browser Tool Policy for details.

Where relevant, actions can be performed on both the source site and the rendered components. Examples are clicking on mobile menus to expand them, or interacting with popups / overlays to dismiss them.

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

Menu items are **read-only** via JSON:API (can list but not create/update/delete — returns 405). Manage menus through the Drupal admin UI at `/admin/structure/menu/manage/<menu-name>` using browser automation (`claude-in-chrome` MCP). See the content-management skill for details.

**Note:** The `menu_items--*` types require the `jsonapi_menu_items` contributed module. If the endpoint returns 404, install it: `ddev composer require drupal/jsonapi_menu_items && ddev drush en jsonapi_menu_items -y`.

**JSON:API defaults to read-only mode** on standard Drupal CMS. If write operations return 405, enable write mode: `ddev drush config:set jsonapi.settings read_only false -y`.

# Drupal CMS Admin Paths

Standard Drupal CMS uses standard Drupal admin paths:

- Site name/slogan: `ddev drush config:set system.site name '<name>' -y`
- Front page: `ddev drush config:set system.site page.front '/home' -y`
- Logo/favicon: `/admin/appearance/settings/mercury` (Mercury theme settings)
- URL aliases: `/admin/config/search/path`
- Redirects: `/admin/config/search/redirect`
- Menu management: `/admin/structure/menu/manage/<menu>`
- API clients (OAuth): `/admin/config/services/api-clients`
- JSON:API settings: `/admin/config/services/jsonapi`

# Canvas Page Regions

Header and footer on Drupal CMS with Canvas are rendered via **Canvas page regions**, not directly by JS components. Page regions default to `status: false` on fresh installs.

Enable them:
```bash
ddev drush config:set canvas.page_region.mercury.header status true -y
ddev drush config:set canvas.page_region.mercury.footer status true -y
```

Mercury SDC components (`sdc.mercury.navbar`, `sdc.mercury.footer`) with Drupal block components (`block.system_branding_block`, `block.system_menu_block.main`) are used in page regions. Custom JS header/footer components can be used in page content but not in page regions.

# Canvas Editor

Drupal CMS with Canvas provides web-based editors for inspecting deployed components and composing pages:

- **Component Code Editor** — `<CMS_URL>/canvas/code-editor/component/<name>`: View the deployed component source code, props, slots, and a live preview. Use this to verify that uploaded components match your local source and have correct prop/slot definitions.
- **Page Editor** — `<CMS_URL>/canvas/editor/canvas_page/<id>`: Visual page composition tool showing the component tree. Use this to inspect how components are nested, debug slot/parent relationships, and verify page structure.

The CMS URL is configured in `canvas/.env` as `CANVAS_SITE_URL`.

# Canvas Documentation

Use the `canvas-docs-explorer` skill to look up Canvas and Drupal CMS documentation:

```
/canvas-docs-explorer <query>
```

Examples:

- `/canvas-docs-explorer known issues and limitations`
- `/canvas-docs-explorer creating custom components`
- `/canvas-docs-explorer page regions configuration`

**Critical platform constraints:**

- **Never remove components via the Component Library UI** — triggers an error that can break the site. Use the Code component panel instead.
- Tailwind directives work in `global.css` only, not in component-specific CSS.
- Tailwind square bracket notation does not work with `@apply` — use `@theme` variables.

Official docs:
- Canvas: `https://project.pages.drupalcode.org/canvas/`
- Code Components: `https://project.pages.drupalcode.org/canvas/code-components/`
- Packages (FormattedText, cn, CVA, SWR): `https://project.pages.drupalcode.org/canvas/code-components/packages/`
- Data Fetching (getPageData, getSiteData, JsonApiClient): `https://project.pages.drupalcode.org/canvas/code-components/data-fetching/`
- Drupal CMS: `https://new.drupal.org/docs/drupal-cms`

# Canvas-Starter Reference

Canonical Canvas component development reference skills from the official canvas-starter are available at `.claude/reference/canvas-starter/` (installed via `canvas-cc-starter` package, symlinked on `npm install` in the canvas/ subdirectory).

# Available Commands

All npm commands must be run from the `canvas/` subdirectory. From the project root, prefix with `cd canvas &&`.

- `cd canvas && npm run code:check`: Run code checks on the components.
- `cd canvas && npm run code:fix`: Run code checks on the components and attempt to fix them.
- `cd canvas && npm run canvas:validate`: Run validation checks for Drupal Canvas against the components. Can take `-c <component>` to narrow the scope to a specific component. Additional options must come after a `--`.
- `cd canvas && npm run canvas:upload`: Upload the components to Drupal CMS. Can take `-c <component>` to narrow the scope to a specific component. Additional options must come after a `--`.
- `cd canvas && npm run canvas:ssr-test`: Run SSR smoke test — renders every component server-side with no props to catch runtime crashes before uploading.
- `cd canvas && npm run canvas:preflight`: Run full pre-upload validation pipeline (code:check → canvas:validate → canvas:ssr-test). Always run before `canvas:upload`.
- `cd canvas && npm run content`: Interact with content in the Drupal site.
- `ddev drush <command>`: Run Drupal drush commands (from project root).
