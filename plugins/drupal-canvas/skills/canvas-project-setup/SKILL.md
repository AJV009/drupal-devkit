---
name: canvas-project-setup
description: Use when setting up a new Drupal CMS project with Canvas for component development. Covers DDEV, JSON:API write mode, Canvas OAuth client, permissions, page regions, menus, project scaffolding, .env, CSS layer fix, and Storybook validation. Every step is idempotent — safe to re-run.
---

# Drupal CMS + Canvas Setup

Idempotent setup for Drupal CMS with Canvas. Safe to re-run on fresh, partial, or fully configured projects.

## Architecture

Two APIs, both via OAuth 2.0 Client Credentials:

| API | Base Path | Purpose | CLI |
| --- | --------- | ------- | --- |
| Canvas REST API | `/canvas/api/v0/` | Component upload/management | `canvas:upload` |
| JSON:API | `/jsonapi` | Content management (pages, media) | `content` |

## Step 1: Detect State (Single Batch)

Run ALL checks in one compound command. Parse the output to decide which steps to skip.

```bash
echo "=== STATE CHECK ===" && \
echo "--- ddev ---" && ddev describe -j 2>/dev/null | jq -r '.raw.name // "not_configured"' && \
echo "--- drupal ---" && ddev drush status --field=bootstrap 2>/dev/null || echo "not_installed" && \
echo "--- jsonapi_readonly ---" && ddev drush config:get jsonapi.settings read_only 2>/dev/null || echo "unknown" && \
echo "--- jsonapi_menu_items ---" && (ddev drush pm:list --type=module --status=enabled --field=name 2>/dev/null | grep -q jsonapi_menu_items && echo "installed" || echo "missing") && \
echo "--- page_regions ---" && ddev drush config:get canvas.page_region.mercury.header status 2>/dev/null || echo "unknown" && \
echo "--- social_media_menu ---" && ddev drush eval "echo \Drupal::entityTypeManager()->getStorage('menu')->load('social-media') ? 'exists' : 'missing';" 2>/dev/null || echo "unknown" && \
echo "--- canvas_project ---" && (test -f canvas/package.json && echo "exists" || echo "missing") && \
echo "--- env ---" && (test -f canvas/.env && grep -q CANVAS_SITE_URL canvas/.env && echo "configured" || echo "missing") && \
echo "--- css_layer_fix ---" && (grep -q 'md\\:grid-cols' canvas/src/components/global.css 2>/dev/null && echo "present" || echo "missing") && \
echo "--- storybook ---" && (test -f canvas/node_modules/.bin/storybook && echo "installed" || echo "missing") && \
echo "=== END ==="
```

Log which steps will execute vs skip based on this output.

## Step 2: DDEV + Drupal CMS

**Skip if:** Drupal bootstrap returns `Successful`.

**Fresh install:**
```bash
mkdir <project-name> && cd <project-name>
ddev config --project-type=drupal11 --docroot=web
ddev composer create-project drupal/cms
ddev launch
```

**DDEV configured but Drupal not installed:**
```bash
ddev start && ddev drush site:install --existing-config -y
```

## Step 3: Batch Drush Configuration

Run ALL drush config in one chained command. Each sub-command is idempotent.

```bash
# JSON:API write mode
ddev drush config:set jsonapi.settings read_only false -y && \
# Page regions
ddev drush config:set canvas.page_region.mercury.header status true -y && \
ddev drush config:set canvas.page_region.mercury.footer status true -y && \
# Permissions (safe to re-run — won't duplicate)
ddev drush role:perm:add authenticated 'create url aliases,administer url aliases,create canvas_page content,edit any canvas_page content,delete any canvas_page content,view media'
```

## Step 4: Install jsonapi_menu_items

**Skip if:** Already installed (detected in Step 1).

```bash
ddev composer require drupal/jsonapi_menu_items && ddev drush en jsonapi_menu_items -y
```

Provides `/jsonapi/menu_items/<menu>` endpoints for Canvas navigation components.

## Step 5: Create Social-Media Menu + Clean Footer

**Skip social-media if:** Already exists (detected in Step 1).

```bash
# Create social-media menu
ddev drush eval "\$menu = \Drupal\system\Entity\Menu::create(['id' => 'social-media', 'label' => 'Social media']); \$menu->save();"

# Remove default footer items (Privacy policy, My privacy settings)
ddev drush eval "\$items = \Drupal::entityTypeManager()->getStorage('menu_link_content')->loadByProperties(['menu_name' => 'footer']); foreach (\$items as \$item) { if (in_array(\$item->getTitle(), ['Privacy policy', 'My privacy settings'])) { \$item->delete(); } }"
```

## Step 6: Canvas Project + .env

**Skip if:** `canvas/.env` exists with `CANVAS_SITE_URL` (detected in Step 1).

```bash
# Install dependencies if needed
cd canvas && npm install

# Create .env from example
cp .env.example .env

# Auto-detect DDEV URL and configure
DDEV_PROJECT=$(ddev describe -j | jq -r '.raw.name')
sed -i "s|https://<project>.ddev.site|https://${DDEV_PROJECT}.ddev.site|" .env
```

Verify `.env` has these values:
```env
CANVAS_SITE_URL=https://<project>.ddev.site
CANVAS_JSONAPI_PREFIX=jsonapi
CANVAS_CLIENT_ID=canvas_cli
CANVAS_CLIENT_SECRET=canvas_secret
CANVAS_COMPONENT_DIR=./src/components
CONTENT_NO_AUTH=true
```

If `CANVAS_COMPONENT_DIR` is missing, add it. This is a common cause of "No local components found" errors.

## Step 7: OAuth Client (Browser Automation Required)

**Skip if:** Client already exists:
```bash
ddev drush eval "echo \Drupal::entityTypeManager()->getStorage('consumer')->loadByProperties(['client_id' => 'canvas_cli']) ? 'exists' : 'missing';"
```

This is the ONLY step requiring browser automation. Navigate to `/admin/config/services/api-clients` in Claude Chrome.

Create a new API client:

| Field | Value |
| ----- | ----- |
| Label | Canvas CLI |
| Machine name | `canvas_cli` |
| Secret | `canvas_secret` |

**Three critical settings (all required — missing any one causes silent auth failures):**

1. **Grant type:** Enable "Client Credentials"
2. **Scopes:** Add ALL three: `canvas:asset_library`, `canvas:js_component`, `member`
3. **Client Credentials → User:** Assign your admin user account

**The user assignment is the #1 missed step.** Without it, OAuth tokens are valid but the Canvas REST API returns 401.

## Step 8: CSS Layer Specificity Fix (CRITICAL)

**This step prevents the single biggest time sink in Canvas development.**

Mercury theme CSS is non-layered. Canvas Tailwind generates utilities inside `@layer utilities`. Per CSS spec, non-layered styles ALWAYS beat layered styles regardless of specificity. This means ALL responsive Tailwind utilities (`md:block`, `md:grid-cols-3`, `lg:flex`, etc.) silently fail on the live site even though they work in Storybook.

**Detection:** After Step 7, upload a test and check if responsive classes work:

```bash
# Quick detection: does md:block actually work at desktop width?
# This can also be tested via Playwright after the site is live
```

**Fix:** Ensure `global.css` has the responsive override block. If missing, add it:

```css
/* Make Canvas slot wrappers transparent to CSS grid/flex layouts */
astro-slot {
  display: contents;
}

/* Mercury theme CSS overrides Canvas Tailwind responsive utilities (layered vs non-layered cascade).
   Force responsive grid/display overrides to take priority. */
@media (min-width: 768px) {
  .md\:grid-cols-2 { grid-template-columns: repeat(2, minmax(0, 1fr)) !important; }
  .md\:grid-cols-3 { grid-template-columns: repeat(3, minmax(0, 1fr)) !important; }
  .md\:grid-cols-4 { grid-template-columns: repeat(4, minmax(0, 1fr)) !important; }
  .md\:grid-cols-5 { grid-template-columns: repeat(5, minmax(0, 1fr)) !important; }
  .md\:block { display: block !important; }
  .md\:flex { display: flex !important; }
  .md\:hidden { display: none !important; }
}
@media (min-width: 1024px) {
  .lg\:grid-cols-3 { grid-template-columns: repeat(3, minmax(0, 1fr)) !important; }
  .lg\:grid-cols-4 { grid-template-columns: repeat(4, minmax(0, 1fr)) !important; }
  .lg\:block { display: block !important; }
  .lg\:flex { display: flex !important; }
  .lg\:hidden { display: none !important; }
}
```

**Important:** This is a STARTER set. As components use more responsive utilities, new overrides may be needed. When a responsive class doesn't work on the live site, add its `!important` override here — don't debug the class itself.

Also add the `astro-slot` fix if missing — Canvas wraps slot children in `<astro-slot>` elements that break CSS grid/flex layouts.

## Step 9: Validate + Storybook

```bash
# Validate Canvas CLI connection
cd canvas && npm run canvas:validate

# Start Storybook in background and verify it loads
cd canvas && npx storybook dev -p 6006 &
# Wait for startup, then verify
sleep 10 && curl -s -o /dev/null -w "%{http_code}" http://localhost:6006
```

If `canvas:validate` fails, check `.env` (Step 6) and OAuth client (Step 7).

## Step 10: Cache Rebuild

```bash
ddev drush cache:rebuild
```

## Step 11: Regenerate JSON:API Spec (Optional)

**Skip if:** `.claude/skills/content-management/jsonapi_specification.json` exists and is > 1KB.

```bash
DDEV_URL=$(ddev describe -j | jq -r '.raw.primary_url')
curl -s "${DDEV_URL}/jsonapi/open_api/jsonapi" > .claude/skills/content-management/jsonapi_specification.json 2>/dev/null || echo "OpenAPI spec endpoint not available — skipping"
```

Requires `openapi` + `openapi_jsonapi` modules. Safe to skip — content scripts work without it.

## Output: Setup Report

After completing all steps, write a structured report:

```
=== SETUP REPORT ===
DDEV: running (project: <name>)
Drupal: installed (bootstrap: Successful)
JSON:API: write mode enabled
jsonapi_menu_items: installed
Page regions: header=true, footer=true
Social-media menu: created
Footer cleanup: done (removed N default items)
Canvas project: scaffolded, dependencies installed
.env: configured (URL: https://<project>.ddev.site)
OAuth client: created (canvas_cli, 3 scopes, user assigned)
CSS layer fix: applied (N responsive overrides in global.css)
Storybook: running on port 6006
Validation: canvas:validate passed
Cache: rebuilt
=== READY FOR DEVELOPMENT ===
```

## Platform Gotchas (Learned from Production)

These are hard-won lessons. Read them before debugging anything.

### CSS Layer Specificity (Mercury vs Tailwind)
Mercury theme CSS is non-layered. Canvas Tailwind utilities are layered (`@layer utilities`). Non-layered CSS ALWAYS wins regardless of specificity or media queries. Every responsive Tailwind class (`md:block`, `lg:grid-cols-3`, etc.) silently fails on the live site. Fix: `!important` overrides in `global.css`. See Step 8.

### astro-slot Breaks Grid/Flex
Canvas wraps slot children in `<astro-slot>` elements. These are block-level by default, breaking CSS grid and flex layouts. Fix: `astro-slot { display: contents; }` in `global.css`.

### Slot Hydration Failures
Complex slot-based components may render correctly server-side but fail during client-side hydration. The `await-children` attribute on `canvas-island` elements can cause the Canvas runtime to silently drop the component tree. Fix: Use flat components with direct props instead of deeply nested slot compositions. Test slot-based components on the live site early, not just via SSR.

### Never Use `drush eval` for Page Entity Manipulation
Calling `$page->save()` with incomplete data wipes all page components. Use JSON:API PATCH or the Canvas Page Editor UI instead. The `drush eval` approach has caused complete page content wipes in production.

### Upload CLI Syntax
The correct syntax for uploading a specific component is:
```bash
cd canvas && npm run canvas:upload -- -- -c <component_name>
```
Note the double `--` — first for npm, second for the Canvas CLI. Multi-component: `-c name1 -c name2`.

### Components Removed via Library UI
Never remove components through the Component Library admin UI — it triggers an error that can break the site. Use the Code component panel at `/canvas/code-editor/component/<name>` instead.

### Tailwind Directives
Tailwind `@apply`, `@screen`, etc. only work in `global.css`, NOT in component-specific CSS files. Tailwind square bracket notation does not work with `@apply` — use `@theme` variables instead.

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| "No local components found in ./components" | `CANVAS_COMPONENT_DIR` not set | Add `CANVAS_COMPONENT_DIR=./src/components` to `.env` |
| "Client authentication failed" | Wrong client ID/secret | Check machine name (not label) at `/admin/config/services/api-clients` |
| 401 "You must be logged in" | OAuth valid but no user assigned | Assign admin user in Client Credentials settings on API client |
| HTTP 405 on JSON:API writes | Read-only mode (default) | `ddev drush config:set jsonapi.settings read_only false -y` |
| 403 on page creation (path alias) | Missing URL alias permissions | `ddev drush role:perm:add authenticated 'create url aliases,administer url aliases'` |
| Empty header/footer | Page regions disabled | `ddev drush config:set canvas.page_region.mercury.header status true -y` |
| 404 on `/jsonapi/menu_items/main` | Module not installed | `ddev composer require drupal/jsonapi_menu_items && ddev drush en jsonapi_menu_items -y` |
| Responsive classes don't work on live site | CSS layer specificity | Add `!important` overrides to `global.css` (Step 8) |
| Grid/flex layout broken with slots | `astro-slot` is block-level | Add `astro-slot { display: contents; }` to `global.css` |
| Component visible in Storybook but invisible on site | `status: false` in component.yml | Set `status: true` and re-upload |
