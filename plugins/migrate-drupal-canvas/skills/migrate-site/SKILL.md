---
name: migrate-site
description: 'Full site migration to Drupal CMS using specialized sub-agents. Discovers all pages, extracts verbatim content and responsive CSS, builds missing components with Storybook visual verification, uploads to Drupal CMS, configures site identity and menus, creates all page content from verbatim text files, and validates every page visually against the source with side-by-side comparison. Invoke with /migrate-site <source-url>. Handles complete multi-page site migration including branding, navigation, media assets, layout matching, and structured post-migration review.'
---

# Full Site Migration to Drupal CMS

Migrate an entire website into Drupal CMS — every page, every menu, every asset — validated visually against the original.

## Arguments

- `$1` — **Source site URL** (required). The origin website to migrate from. Example: `https://example.com`

## Execution Mode

**AUTONOMOUS EXECUTION — DO NOT ASK FOR USER INPUT.**

This skill runs end-to-end without asking for user confirmation or approval. Make decisions independently — but decisions must be informed by reading source HTML/CSS, component specifications, and Canvas documentation before acting. Never use plan mode (it requires user approval). Never ask "should I proceed?" or "would you like me to..." — just do it.

**Autonomous does NOT mean fast or careless.** You must still:
- Verify after every upload (screenshot the live site)
- Follow incremental deployment (one component at a time)
- Take per-section screenshots (not full-page)
- Consult docs before each phase
Skipping verification steps to move faster is a skill violation, not efficiency.

Before each phase, reason through what needs to happen step by step. Read `component.yml` AND `index.jsx` before composing JSON. Map full component trees before writing content. Think hard — autonomous doesn't mean impulsive.

If a step fails, attempt to fix it. If it cannot be fixed after two attempts, log the failure in the migration artifacts and move on to the next step.

## Sub-Agent Architecture

This skill uses specialized sub-agents for different phases. The main session acts as an orchestrator — it delegates work, collects results, and coordinates phase transitions. It does NOT do the heavy lifting itself.

### Available Agents

| Agent | Model | When Used |
|-------|-------|-----------|
| `project-setup` | Sonnet | Phase -1: Full Drupal CMS + Canvas setup (DDEV, config, OAuth, CSS layer fix, Storybook) |
| `site-analyzer` | Sonnet | Phase 0-1: Crawl source, extract verbatim content, take screenshots |
| `css-extractor` | Sonnet | Phase 0-1: Multi-viewport CSS analysis |
| `component-auditor` | Sonnet | Phase 2: Audit components against section requirements, identify gaps |
| `component-builder` | Opus | Phase 3: Build components with structural Storybook verification |
| `storybook-qa` | Sonnet | Phase 3.5: Visual QA scan — compare Storybook renders against source screenshots |
| `component-fixer` | Opus | Phase 3.5: Targeted fix for ONE QA issue at a time |
| `upload-verifier` | Sonnet | Phase 4: Preflight, disable-all, enable-one-at-a-time with live verification |
| `media-handler` | Haiku | Phase 5: Download and upload media assets |
| `site-configurator` | Sonnet | Phase 6: Site identity (name, logo, favicon) and page path aliases |
| `menu-builder` | Sonnet | Phase 6: Create and configure all menus via browser automation |
| `content-composer` | Opus | Phase 7: Compose page JSON from verbatim content files |
| `phase-verifier` | Haiku | Phase 4, 7: Focused single-target verification (component smoke test, section check, page check) |
| `artifact-checker` | Haiku | Phase transitions: Validates artifacts before allowing next phase |
| `visual-verifier` | Sonnet | Phase 8: Comprehensive final review across ALL pages with responsive testing |

### Orchestrator Responsibilities

The main session (orchestrator) is a **lightweight coordinator**. It spawns agents, verifies their output artifacts, and decides when to proceed. It does NOT do heavy lifting itself — every phase is delegated to a specialized agent.

The orchestrator handles ONLY:
- Pre-flight checks (5 bash commands)
- Phase transitions: read agent output, verify artifacts are complete, decide next phase
- Spawning agents with the correct inputs for each phase
- Handling agent failures: re-run with specific instructions, or log to `blocked.md`
- Treat agent warnings about rendering failures (e.g., "header and footer render empty") as blockers — investigate before proceeding to the next phase
- Brief live-site spot-checks via Claude Chrome between phases (single refresh + glance, not section-by-section review)

The orchestrator does NOT:
- Read component source code (component-auditor does this)
- Build or modify components (component-builder does this)
- Upload or enable components (upload-verifier does this)
- Extract content from the source site (site-analyzer does this)
- Download or upload media (media-handler does this)
- Configure site settings or page paths (site-configurator does this)
- Create menu items (menu-builder does this)
- Compose page JSON (content-composer does this)
- Perform visual comparisons (visual-verifier does this)

### Orchestrator Skill Prohibition

**The orchestrator NEVER invokes skills directly.** All skill-dependent work is delegated to agents that have those skills. This prevents skill content from loading into the orchestrator's context and wasting tokens.

| Skill | Used By Agent(s) |
|-------|------------------|
| `canvas-docs-explorer` | component-auditor, upload-verifier, site-configurator, menu-builder, component-builder, component-fixer |
| `drupal-cms-setup` | project-setup (Phase -1) |
| `component-authoring` | component-builder, component-fixer, component-auditor, upload-verifier, content-composer |
| `create-component` | component-builder |
| `stories` | component-builder |
| `content-management` | content-composer, menu-builder |

If the orchestrator needs platform info, it checks SKILL.md's Troubleshooting section or delegates a targeted query to the agent that has the skill.

### Agent Dispatch

Custom agents are defined in `.claude/agents/`. Spawn them using the Agent tool with the agent's `name` field as `subagent_type`. Always provide a detailed prompt with all input file paths — agents start with no context.

| Phase | Agent | subagent_type | run_in_background |
|-------|-------|--------------|-------------------|
| -1 | project-setup | `project-setup` | No (must complete before any migration work) |
| 0-1 | site-analyzer | `site-analyzer` | No (need artifacts before Phase 2) |
| 0-1 | css-extractor | `css-extractor` | No (need artifacts before Phase 2) |
| 2 | component-auditor | `component-auditor` | No |
| 3 | component-builder | `component-builder` | No (need components before Phase 3.5) |
| 3.5 | storybook-qa | `storybook-qa` | No (orchestrator dispatches per iteration) |
| 3.5 | component-fixer | `component-fixer` | No (orchestrator dispatches per issue) |
| 4 | upload-verifier | `upload-verifier` | No |
| 4 | phase-verifier | `phase-verifier` | Yes (parallel per-component smoke tests) |
| 5 | media-handler | `media-handler` | **Yes** — launch alongside Phase 3 |
| 6 | site-configurator | `site-configurator` | No |
| 6 | menu-builder | `menu-builder` | Launch in parallel with site-configurator |
| 7 | content-composer | `content-composer` | No (need page deployed before verify) |
| 7 | phase-verifier | `phase-verifier` | Yes (verify page N while composing page N+1) |
| 1→2 | artifact-checker | `artifact-checker` | No (gate before Phase 2) |
| 2→3 | artifact-checker | `artifact-checker` | No (gate before Phase 3) |
| 3→3.5 | artifact-checker | `artifact-checker` | No (gate before Phase 3.5) |
| 3.5→4 | artifact-checker | `artifact-checker` | No (gate before Phase 4) |
| 4→5 | artifact-checker | `artifact-checker` | No (gate before Phase 5) |
| 8 | visual-verifier | `visual-verifier` | No (final review, need results) |

**Parallel launch examples:**
- Phase 0-1: Launch `site-analyzer` AND `css-extractor` in one message (two Agent tool calls)
- Phase 5: Launch `media-handler` with `run_in_background: true` as early as Phase 3
- Phase 6: Launch `site-configurator` AND `menu-builder` in one message
- Phase 7: After `content-composer` finishes page N, launch `phase-verifier` for page N with `run_in_background: true`, then immediately start `content-composer` for page N+1

### Content Fidelity Rule

**The #1 failure mode of previous migrations was text hallucination.** After context compaction, the agent had no verbatim text reference and fabricated plausible-sounding but factually wrong copy for every paragraph, card description, and subtitle.

**Prevention:** The `site-analyzer` agent extracts ALL text verbatim into `docs/migration/content/<page>.md` files. These files are the ONLY source of truth for text content. The `content-composer` agent copies text character-for-character from these files. It NEVER generates text. If text is missing from the content file, it flags `[MISSING CONTENT]` rather than inventing.

## Principles

These are not guidelines — they are the standards that separate a faithful migration from a superficial copy.

- **Understand before you build.** Read source HTML, CSS, and JS. Inspect DOM structure, computed styles, layout properties. Screenshots show what something looks like; source code shows what it *is*. You need both.
- **Every section is a product.** A footer with logo, contact info, 3 menu columns, social links, and copyright is not "a footer" — it is an information architecture. Treat every section with the depth it deserves.
- **Explore when things fail.** "Access denied" is information, not a wall. Browse admin menus, try adjacent paths, research the platform.
- **Save your evidence.** Screenshots, structural notes, verbatim content files, and component interface plans survive context compaction. Your future self (or a resumed session) needs them.
- **Verify structurally, not just visually.** A footer that "looks like a footer" but can't render menus is broken. Check that menus populate, slots render children, images load from media entities, and links resolve.
- **Migrate the whole site.** Discover and migrate every page, not just one.
- **Artifacts are your memory.** Write them diligently — a new session should be able to resume seamlessly from `progress.md`.
- **Read before writing.** Always check existing artifacts before creating new ones. Always read `component.yml` AND `index.jsx` before composing component JSON.
- **Visual fidelity matters.** Extract design tokens and match the source site's styling exactly. Dark backgrounds, gradients, glass effects — replicate them.
- **Site configuration is content.** Menus, site name, logo, footer — these are part of the migration, not optional extras.
- **Content fidelity is non-negotiable.** Every heading, paragraph, button label, and card description on the target must match the source exactly. Verbatim text extraction → verbatim text composition. No rephrasing, no "improving," no generating.

## Exploration Mindset

When something fails or is unexpected, **investigate before logging as blocked**. This is a migration, not a checklist — the platform may work differently than expected.

- **"Access denied" means try another path.** Drupal CMS admin paths are standard Drupal. If one path fails, browse `/admin/config/system/` to discover what's available.
- **Browse admin menus.** Navigate to `/admin` and explore the menu tree. Click into categories. Read labels. The admin UI is discoverable.
- **Use all available tools.** Browser automation, Canvas Code Editor, Storybook, Playwright, `cd canvas && npm run content` — each gives a different view. When one fails, try another.
- **Research the platform.** Drupal CMS with Canvas is a standard Drupal distribution with the Canvas module. Standard Drupal admin paths apply.
- **Try at least 3 alternative approaches** before logging something as blocked. Document what you tried in `decisions.md`.
- **Check the source for clues.** If a feature seems missing, inspect what modules are enabled, what admin paths exist, or what drush commands are available.

## Canvas Editor

Drupal CMS provides web-based editors for inspecting deployed components and composing pages.

| Tool | URL | Purpose |
|------|-----|---------|
| Component Code Editor | `<CMS_URL>/canvas/code-editor/component/<name>` | View deployed component source, props, slots, and live preview |
| Page Editor | `<CMS_URL>/canvas/editor/canvas_page/<id>` | Visual page composition, component tree inspection |

Use the Code Editor to verify that uploaded components have the correct props, slots, and rendering. Use the Page Editor to inspect how components are composed on a page and debug layout issues.

## Browser Tool Policy

Two browser tools are available. They serve different purposes — do not mix them up.

**Claude Chrome (`claude-in-chrome` MCP)** — use for:
- All Drupal admin UI interaction (site settings, menus, form submissions, file uploads)
- All visual verification on the live public site — after uploading a component, adding a page section, or making any visual change, switch to the public site tab in Claude Chrome, refresh, navigate to the relevant page, scroll to the changed section, and look at it. The site URL is in `.env` as `CANVAS_SITE_URL` (on DDEV, this is the same as the public URL).
- The user is watching the Chrome browser in real time. Every time you navigate to the live site and verify something visually, the user sees it too. This is the primary way the user monitors migration progress — make it count.

**Playwright** — use for:
- Storybook navigation and component preview during development
- Source site inspection: DOM structure, computed CSS, element hierarchy, content extraction
- Bulk data gathering from public pages (scraping text, images, URLs)
- Any headless/background browser work that doesn't need to be visible to the user

**The rule:** If the action should be visible to the user watching the migration (admin changes, live site verification, visual comparisons), use Claude Chrome. If the action is background development work (inspecting source, checking Storybook, extracting data), use Playwright.

**After every major visual change** (component upload, page content creation, section update, site config change), switch to the public site in Claude Chrome and refresh. Navigate to the page and section you just changed. The user is evaluating your work in real time — show them the result.

## Migration Artifacts

All migration state is persisted to `docs/migration/` in the repo root. This serves as memory across sessions if context runs out.

### Required artifact files

| File | Purpose |
| --- | --- |
| `docs/migration/plan.md` | Full migration plan: page inventory, section inventories, component mapping |
| `docs/migration/section-reference.md` | Section-to-screenshot mapping with structural notes for each section |
| `docs/migration/content/<page>.md` | **Verbatim text content** for each page — one file per page, extracted by site-analyzer |
| `docs/migration/css-audit.md` | Responsive CSS analysis: computed styles at 5 viewport widths, breakpoint transitions |
| `docs/migration/design-tokens.md` | Global theme tokens: colors, gradients, typography, spacing, effects |
| `docs/migration/media-map.md` | Table of downloaded media: source URL → local path → target_id |
| `docs/migration/progress.md` | Current progress: which pages/sections are done, which remain, any blockers |
| `docs/migration/decisions.md` | Decisions made autonomously: component choices, approximations, skipped items |
| `docs/migration/blocked.md` | All blocked, failed, or skipped operations for the user to review and retry |

### Artifact rules

- **Create `docs/migration/` at the start.** Write `plan.md` first.
- **Update after every phase and after every page.** Keep `progress.md` current so a new session can pick up exactly where the last one left off.
- **Keep data unique and concise.** No prose padding. Use tables and bullet points. Every line should carry information — no filler, no duplication across files.
- **Before starting work, always read existing artifacts.** If `progress.md` exists, resume from where it stopped.
- **On errors or blockers**, append to `decisions.md` with the error, what was tried, and the resolution or workaround.
- **On failures that cannot be resolved**, log them to `docs/migration/blocked.md` with enough detail for the user to act on. Then move on.
- **On resuming**, read `blocked.md` first. If the user has resolved items (marked with `[x]`), retry those operations before continuing.
- **Content files are sacred.** The `docs/migration/content/<page>.md` files contain verbatim source text. Never edit them to "improve" the text. Only edit to fix extraction errors (e.g., missing sections, garbled characters).

### Artifact format example

`progress.md`:

```markdown
# Migration Progress

Source: https://example.com Target: https://efi-ed.ddev.site Started: 2026-03-10

## Phases

- [x] Phase -1: Drupal CMS Setup
- [x] Phase 0-1: Discovery + Deep Analysis (parallel agents)
- [x] Phase 2: Component audit
- [x] Phase 3: Build missing components
- [x] Phase 3.5: Storybook QA loop
- [x] Phase 4: Upload components
- [ ] Phase 5: Media assets (7/12 done)
- [ ] Phase 6: Site configuration
- [ ] Phase 7: Page content
- [ ] Phase 8: Post-migration review

## Pages

| # | Page | Path | Status |
|---|------|------|--------|
| 1 | Homepage | / | Content ready |
| 2 | Services | /services | Not started |
| 3 | About | /about | Not started |
| 4 | Contact | /contact | Not started |

## Site Configuration

- [ ] Site name
- [ ] Logo
- [ ] Favicon
- [ ] Main menu (0/4 items)
- [ ] Footer menu (0/8 items)
- [ ] Social media menu (0/3 items)
```

`blocked.md`:

```markdown
# Blocked / Failed Operations

Items the migration could not complete. Mark with [x] once resolved, and the next run will retry them automatically.

## API / Auth Failures

- [ ] `cd canvas && npm run content -- create content/page/new-about.json` — 422 Unprocessable Entity: "langcode: permission denied". Remove langcode field from JSON before retrying.

## Media Downloads

- [ ] `https://example.com/hero-bg.webp` — 403 Forbidden. Asset behind auth. Needs manual download to `/tmp/migration-hero-bg.webp`.

## Site Configuration

- [ ] Site name — browser automation failed, admin UI not accessible. Set manually at /admin/config/system/site-information.
- [ ] Logo upload — file too large for admin UI upload. Resize and retry.

## Content / Page Composition

- [ ] Section 4 (Testimonials) — 422: "inputs.quote: field is required". Component expects `quote` prop but content used `text`.

## Out of Scope

- [ ] Contact form — platform does not support webforms. Left as placeholder component. Requires manual setup or third-party integration.
```

`section-reference.md`:

```markdown
# Section Reference

Visual and structural reference for each section across all pages. Screenshots saved to `docs/migration/screenshots/`.

## Homepage

| # | Section | Screenshot (Desktop) | Screenshot (Mobile) | Structure |
|---|---------|-----------|-------------------|-----------|
| 1 | Hero banner | `screenshots/pages/home/desktop/section-01-hero.png` | `screenshots/pages/home/mobile/section-01-hero.png` | Full-width, background image, h1 + subtitle + CTA button, dark overlay |
| 2 | Services grid | `screenshots/pages/home/desktop/section-02-services.png` | `screenshots/pages/home/mobile/section-02-services.png` | 3-column card grid, icon + heading + text per card |
| 3 | About preview | `screenshots/pages/home/desktop/section-03-about.png` | `screenshots/pages/home/mobile/section-03-about.png` | 2-column: image left, text + button right |
| 4 | Footer | `screenshots/pages/home/desktop/section-04-footer.png` | `screenshots/pages/home/mobile/section-04-footer.png` | 4-column: logo+tagline, 2 menu columns, contact info. Social icons row. Copyright bar. |

Full-page screenshots: `screenshots/pages/home/desktop/full-page.png`, `screenshots/pages/home/mobile/full-page.png`

## Cross-Page Elements

| Element | Screenshot (Desktop) | Screenshot (Mobile) | Structure |
|---------|-----------|-------------------|-----------|
| Header | `screenshots/global/header-desktop.png` | `screenshots/global/header-mobile.png` | Logo left, main menu center, CTA button right. Sticky. |
| Footer | `screenshots/global/footer-desktop.png` | `screenshots/global/footer-mobile.png` | Logo + tagline column, Services menu, Company menu, contact info. Social row. Copyright. |
```

`content/homepage.md` (example):

```markdown
# Homepage Content (Verbatim)

Source: https://example.com/
Extracted: 2026-03-11 via Playwright

## Section 1: Hero

### h1
AI Implementation Specialists

### subtitle (p)
We build the AI frameworks others use. From strategy to production, we help organisations transform with AI that actually works.

### button 1
Text: "Explore Solutions"
Link: /services
Variant: primary (solid white on dark)

### button 2
Text: "Get In Touch"
Link: /contact
Variant: outline-light

## Section 2: What We Do

### h2
What We Do

### cards

#### Card 1: AI Strategy
Heading: AI Strategy
Text: We sit with your leadership team, identify the highest-impact opportunities, and build an AI roadmap you can actually execute.
Link text: Learn more
Link href: /services
```

## Pre-flight Checks

Before starting, verify the project is ready. The `project-setup` agent (Phase -1) handles all configuration. After it completes, the orchestrator only needs these quick checks:

1. **Check for existing artifacts**: Read `docs/migration/progress.md` if it exists. If a previous session made progress, resume from where it stopped.
2. **Read setup report**: Check `docs/migration/setup-report.md` — confirms all configuration is in place.
3. **Quick validation**: Run `cd canvas && npm run canvas:validate` to confirm Canvas CLI connects.
4. **Content API**: Run `cd canvas && npm run content -- list page` to verify JSON:API read access works.

If any check fails and no setup report exists, spawn the `project-setup` agent. If the setup report exists but validation fails, check the report for which step failed and fix manually.

## State Management

An append-only JSONL journal (`docs/migration/state.jsonl`) tracks every significant action during migration, surviving context compaction. Hooks handle agent-boundary and system logging automatically.

### Phase 0: Create the Journal

Before launching any agents, create the journal and append the `migration_started` event:

```bash
mkdir -p docs/migration
touch docs/migration/state.jsonl
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","phase":0,"agent":"orchestrator","action":"migration_started","detail":{"source_url":"<url>","target_url":"<url>","session_id":"'$(date +%s)'"},"level":"system"}' >> "${CLAUDE_PROJECT_DIR:-.}/docs/migration/state.jsonl"
```

This activates convention-based hooks (SubagentStop, PreCompact, SessionStart) which check for `state.jsonl` existence.

### Phase Transitions

Before moving to the next phase, append a `phase_completed` event:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","phase":N,"agent":"orchestrator","action":"phase_completed","detail":{"phase":N,"summary":"<one-line summary>"},"level":"system"}' >> "${CLAUDE_PROJECT_DIR:-.}/docs/migration/state.jsonl"
```

### Post-Compaction Resume

After compaction, the SessionStart hook prints a context message. The orchestrator must:
1. Spawn the `state-summarizer` agent
2. Read the returned summary (also persisted to `docs/migration/state-summary.md`)
3. Resume migration from the correct phase and step — no guessing

### Migration End

After Phase 8 completes:

```bash
echo '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","phase":8,"agent":"orchestrator","action":"migration_completed","detail":{"pages_deployed":N,"components_enabled":N,"blockers_remaining":N,"total_events":'$(wc -l < docs/migration/state.jsonl)'},"level":"system"}' >> "${CLAUDE_PROJECT_DIR:-.}/docs/migration/state.jsonl"
```

The JSONL file becomes the permanent audit trail for the migration.

## Mandatory Documentation Checkpoints

Each sub-agent fetches its own relevant documentation via the `canvas-docs-explorer` skill as part of its "Before Starting" step. The orchestrator does NOT need to fetch docs — the agents that have the skill handle this:

- **Phase 2**: `component-auditor` fetches docs on components, props, slots, known issues
- **Phase 3**: `component-builder` fetches docs on component structure, props, slots, and known issues via `canvas-docs-explorer`
- **Phase 4**: `upload-verifier` fetches docs on upload behavior and deployment
- **Phase 6**: `site-configurator` fetches docs on site settings and admin paths; `menu-builder` fetches docs on menu management

Agents log which docs they consulted in `docs/migration/decisions.md`.

## Migration Workflow

### Phase -1: Drupal CMS Setup (project-setup agent)

Delegate ALL setup to the `project-setup` agent. This keeps the orchestrator's context clean — setup involves ~15 bash commands, browser automation for OAuth, and CSS layer fixes that would consume significant context.

**Spawn `project-setup` agent** (Sonnet) with:
- The project root directory
- Whether this is a fresh install or an existing project

The agent will:
1. Detect current state (single batched check)
2. Configure DDEV + Drupal if needed
3. Batch all drush config (JSON:API write mode, page regions, permissions, menus)
4. Install jsonapi_menu_items module
5. Scaffold Canvas project + configure `.env`
6. Create OAuth client via browser automation (the only browser step)
7. Apply CSS layer specificity fix to `global.css` (prevents the #1 time sink from previous migrations)
8. Validate Canvas CLI connection
9. Start Storybook

**After the agent completes**, read its setup report. If it reports any failures:
- OAuth client failure: Check browser automation access, retry manually if needed
- Validation failure: Check `.env` and OAuth configuration
- All other failures are non-critical — the agent continues past them

Do NOT proceed to Phase 0-1 until the setup report shows validation passed.

### Phase 0-1: Discovery + Deep Analysis (Parallel Agents)

Launch TWO agents in parallel — use two parallel Agent tool calls in a single message:

**Agent 1: `site-analyzer`** (Sonnet)

Prompt the agent with the source URL. It will:
- Navigate all pages with Playwright (NOT WebFetch — source may be a client-rendered SPA)
- Extract ALL text content VERBATIM using both accessibility tree and DOM textContent
- Save verbatim content to `docs/migration/content/<page>.md` — one file per page
- Take per-section screenshots at 1280px (desktop) and 375px (mobile)
- Build: `plan.md`, `section-reference.md`, `media-map.md` (URLs only, not yet downloaded)

**Agent 2: `css-extractor`** (Sonnet)

Prompt with the source URL and page list (if known from sitemap). It will:
- Extract computed styles at 5 viewport widths (320, 768, 1024, 1280, 1440px)
- Document breakpoint transitions
- Save to `docs/migration/css-audit.md` and `docs/migration/design-tokens.md`

**After both agents complete, verify artifacts:**
- Content files have text for EVERY section (not just headings) — read the files and check that body paragraphs, card descriptions, and button labels are present
- Screenshot directories exist for every page: `ls docs/migration/screenshots/pages/`
- Screenshot count matches section count — `find docs/migration/screenshots/pages/ -name '*.png' | wc -l`
- Content MD files have Context/Layout/Components/Screenshot metadata comments for each section
- CSS audit has entries for every section
- Design tokens file has colors, fonts, and spacing values
- If any artifact is incomplete, re-run the relevant agent with specific instructions to fill gaps

Create `docs/migration/progress.md` and mark Phase 0-1 complete.

**Artifact gate:** Spawn `artifact-checker` (Haiku) with mode `phase-1`. If it returns FAIL, re-run the relevant agent targeting the specific gaps listed. Do not proceed to the next phase until artifact-checker returns PASS.

### Phase 2: Component Audit (component-auditor agent)

Component auditing requires reading every component's `component.yml` AND `index.jsx`, comparing capabilities against every section across all pages, and checking global.css design tokens. This is expensive in the orchestrator's context. Delegate to the `component-auditor` agent.

**Spawn `component-auditor` agent** (Sonnet) with:
- Path to `canvas/src/components/` (all existing components)
- Path to `docs/migration/plan.md` (page inventories with per-page section inventories)
- Path to `docs/migration/section-reference.md` (section structural notes and screenshot paths)
- Path to `docs/migration/css-audit.md` (responsive CSS data)
- Path to `docs/migration/design-tokens.md` (extracted theme tokens)
- Path to `docs/migration/screenshots/` (source section screenshots for visual reference)

The agent will:
1. Read every component's `component.yml` and `index.jsx` to inventory capabilities (props, slots, layout, variants)
2. Map each section across ALL pages to the best-matching component — checking **structural adequacy**, not just name match
3. Identify gaps: sections with no matching component, structurally inadequate components, components needing new props/variants/slots
4. Check `global.css` `@theme` block against design tokens — flag missing colors, gradients, fonts
5. Write the component mapping to `docs/migration/plan.md` and gap list + decisions to `docs/migration/decisions.md`

**After the agent completes**, verify:
- Every section across every page has a component mapping (no unmapped sections)
- Every gap has a clear description of what's needed
- The component mapping is consistent across pages (same section type uses same component)

Update `progress.md`.

**Artifact gate:** Spawn `artifact-checker` (Haiku) with mode `phase-2`. If it returns FAIL, re-run the relevant agent targeting the specific gaps listed. Do not proceed to the next phase until artifact-checker returns PASS.

### Phase 3: Build Missing Components (with Storybook Visual Verification)

For each gap identified in Phase 2 — whether a new component or a modification to an inadequate existing one:

**Spawn `component-builder` agent** (Opus) for each component. The agent will:

1. Read the source section screenshot, CSS audit, design tokens, and verbatim content for that section.
2. Build the component code (`index.jsx` + `component.yml`) following existing patterns.
3. Create a Storybook story at the correct atomic level:
   - Atoms: `canvas/src/stories/atoms/<name>.stories.tsx`
   - Molecules: `canvas/src/stories/molecules/<name>.stories.tsx`
   - Organisms: `canvas/src/stories/organisms/<name>.stories.tsx`
4. Navigate to the Storybook story in Playwright and take a screenshot.
5. Compare the Storybook render against the source section screenshot.
6. Iterate until visual match at both desktop (1280px) and mobile (375px).
7. Run `cd canvas && npm run canvas:validate` and `cd canvas && npm run canvas:ssr-test`.

**Storybook Atomic Structure:**

All stories must be placed in the correct atomic level:
- `canvas/src/stories/atoms/` — button, heading, text, image, spacer, logo, video
- `canvas/src/stories/molecules/` — card, blockquote, logo_card, search_form, search_button, breadcrumb
- `canvas/src/stories/organisms/` — hero, card_container, two_column_text, grid_container, stats_banner, contact_section, header, footer, main_navigation, section
- `canvas/src/stories/templates/` — PageLayout
- `canvas/src/stories/pages/` — Full page compositions (Home, Services, About, Contact)

The component-builder agent creates stories at the correct level with VERBATIM content from `docs/migration/content/`. After individual component stories pass visual verification, compose full-page stories in `canvas/src/stories/pages/` and verify the complete page against the source full-page screenshot.

If no gaps exist, skip this phase. Update `progress.md`.

**Artifact gate:** Spawn `artifact-checker` (Haiku) with mode `phase-3`. If it returns FAIL, re-run the relevant agent targeting the specific gaps listed. Do not proceed to the next phase until artifact-checker returns PASS.

### Phase 3.5: Storybook QA Loop

After the Phase 3 artifact gate passes, run the QA loop. This is a mechanical scan-fix-rescan cycle using only two agents: `storybook-qa` (finds issues) and `component-fixer` (fixes issues). The orchestrator dispatches agents and tracks state — nothing more.

**Orchestrator rules for Phase 3.5:**
- You are a dispatcher. You spawn agents and read their summaries. That's it.
- You MUST NOT read individual issue files beyond their path and status
- You MUST NOT edit any component source files — only component-fixer does that
- You MUST NOT make judgment calls about severity, skip issues, or decide a fix is "good enough"
- You MUST NOT skip the verification re-scan — storybook-qa is the ONLY judge of whether fixes are correct

**The loop — max 3 iterations:**

```
┌─ Iteration N ──────────────────────────────────────────────┐
│  1. SCAN: spawn storybook-qa → finds issues, writes        │
│     docs/migration/issues/NN-*/issue.md + qa-summary.md    │
│  2. READ: orchestrator reads qa-summary.md only             │
│     - If 0 critical/high issues → QA CLEAN → exit loop     │
│     - If issues found → continue to FIX                    │
│  3. FIX: for each open critical/high issue, spawn           │
│     component-fixer with the issue path                    │
│  4. Log iteration to state.jsonl                            │
│  5. Go to next iteration (re-scan to verify fixes)         │
└─────────────────────────────────────────────────────────────┘
```

**Step by step:**

1. Create `docs/migration/issues/` directory

2. **SCAN** — Spawn `storybook-qa` agent (Sonnet) with:
   - Source site URL
   - Storybook base URL (from CLAUDE.md — translate localhost:6006 to the ddev URL)
   - Paths to: `section-reference.md`, `design-tokens.md`, `css-audit.md`, screenshots directory
   - Iteration number (1 = full scan, 2+ = targeted re-scan of previously-fixed components only)

3. **READ summary** — After storybook-qa completes, read ONLY `docs/migration/qa-summary.md`. This file contains a table of issues with severity, component name, and issue path. Do NOT read individual issue.md files.

4. **CHECK** — Count critical/high issues with status `open`:
   - If **0 open critical/high** → log `qa_loop_clean` to state.jsonl → Phase 3.5 complete → continue to artifact gate
   - If **issues remain AND iteration < 3** → continue to FIX
   - If **issues remain AND iteration = 3** → log remaining issues to `blocked.md` → Phase 3.5 complete with known issues

5. **FIX** — For each open critical/high issue listed in qa-summary.md, spawn `component-fixer` agent (Opus) with:
   - The issue directory path (e.g., `docs/migration/issues/01-hero-parallax/`)
   - The component path (from the issue's component field in qa-summary.md)
   - Paths to: `design-tokens.md`, `css-audit.md`
   - The component-fixer reads the issue.md, views screenshots, applies the fix, verifies in Storybook, and updates the issue status (`resolved`, `deferred`, or `open` with incremented fix_attempts)
   - If `fix_attempts >= 2` for an issue, component-fixer auto-escalates to `deferred` and logs to `blocked.md`

6. **LOG** — After all fixers complete for this iteration, append to state.jsonl:
   ```
   {"phase":3.5,"agent":"orchestrator","action":"qa_iteration_complete","detail":{"iteration":N,"issues_found":X,"issues_fixed":Y,"issues_deferred":Z}}
   ```

7. **VERIFY** — Go back to step 2 (SCAN) for the next iteration. The storybook-qa agent will re-scan ONLY the components that were fixed, plus check for regressions from global.css changes. This verification scan is mandatory — do NOT skip it.

**After the loop exits**, update `progress.md`.

**Artifact gate:** Spawn `artifact-checker` (Haiku) with mode `phase-3.5`. If it returns FAIL, review the remaining issues and decide whether to re-run the QA loop or proceed with known issues logged to `blocked.md`. Do not proceed to the next phase until artifact-checker returns PASS.

### Phase 4: Upload & Verify Components (upload-verifier agent)

Upload all components and verify each one renders correctly in the Canvas Code Editor. Delegate the pipeline to the `upload-verifier` agent.

**Spawn `upload-verifier` agent** (Sonnet) with:
- The CMS URL (from `canvas/.env` `CANVAS_SITE_URL`)

The agent will:
1. Run `cd canvas && npm run canvas:preflight` to validate all components locally — fix any failures
2. Upload all components: `cd canvas && npm run canvas:upload`
3. Verify each component in the Canvas Code Editor at `<CMS_URL>/canvas/code-editor/component/<name>`:
   - Props panel matches local `component.yml`
   - Source code panel shows the uploaded `index.jsx`
   - Preview renders without error
   - If error: fix the component, re-upload, re-verify (max 2 attempts)
   - If still broken: log to `docs/migration/blocked.md`
4. Write per-component results to `docs/migration/progress.md`

**After the agent completes**, check its report:
- All components should be verified, or explicitly blocked with reasons
- Spot-check a few components yourself in the Code Editor via Claude Chrome

Do NOT proceed to Phase 5 until every component is individually verified (or explicitly blocked).

Update `progress.md`.

**Artifact gate:** Spawn `artifact-checker` (Haiku) with mode `phase-4`. If it returns FAIL, re-run the relevant agent targeting the specific gaps listed. Do not proceed to the next phase until artifact-checker returns PASS.

### Phase 5: Download Media Assets (media-handler agent, background)

Launch `media-handler` with `run_in_background: true` at the **START of Phase 3** (not after Phase 4). It downloads media while components are being built and uploaded — this phase is fully independent and benefits from early start.

**Spawn `media-handler` agent** (Haiku) with the path to `docs/migration/media-map.md`. The agent will:

1. Download each asset from the source site using original file paths (never image style/thumbnail URLs)
2. Upload each to Drupal CMS media library via `cd canvas && npm run content -- upload`
3. Update `docs/migration/media-map.md` with Media UUIDs and target_ids
4. Verify all uploads

**Critical fix from V3:** Always use original file paths (`/sites/default/files/YYYY-MM/filename.ext`), never style/thumbnail URLs (`/sites/default/files/styles/.../public/...`). Style URLs return AVIF-compressed thumbnails that are too small for production use.

If an image download fails, the agent logs it in `blocked.md` and continues.

Update `progress.md`.

### Phase 6: Site Configuration

Configure the Drupal site settings, page paths, and navigation. Both sub-agents (`site-configurator` and `menu-builder`) handle their own browser setup via `claude-in-chrome` MCP — the orchestrator does NOT interact with the browser in this phase.

Launch `site-configurator` and `menu-builder` in parallel (two Agent tool calls in one message). They don't depend on each other — site identity and menus are independent operations.

Read the `.env` file to extract `CANVAS_SITE_URL` for passing to agents.

#### Site Identity + Page Paths (site-configurator agent)

Site identity setup (name, logo, favicon) and page path alias management require multiple browser automation steps with form inputs, file uploads, and verification. Delegate to the `site-configurator` agent.

**Spawn `site-configurator` agent** (Sonnet) with:
- The CMS URL (from `.env` `CANVAS_SITE_URL`)
- Path to `docs/migration/plan.md` (site identity info: name, logo path, favicon path; page inventory with source paths)
- Path to `docs/migration/logo.svg` or `docs/migration/logo.png` (if available)
- Path to `docs/migration/media-map.md` (for favicon if downloaded)

The agent handles:
- Setting site name via `ddev drush config:set system.site name "<Site Name>" -y` or via `/admin/config/system/site-information`
- Uploading logo via `/admin/appearance/settings/mercury` (Mercury theme settings page) or via drush if a file upload field is available
- Uploading favicon via the same theme settings page
- Verifying front page loads at `/` — creating redirects if needed
- Checking and fixing page path aliases at `/admin/config/search/path` to match source site URLs (e.g., `/services`, `/about`, `/contact`)
- Verifying each page loads at its expected URL on the site

**After the agent completes**, check its report:
- Site name: set or failed
- Logo: uploaded, skipped (inline SVG in header component), or failed
- Favicon: uploaded or failed
- Front page: verified or redirect created
- Page paths: all correct or list of issues
- Any items needing manual intervention go to `blocked.md`

#### Menu Configuration (menu-builder agent)

Menu building via browser automation is extremely expensive (~10-13 tool calls per item) and prone to silent save failures. Delegate ALL menu creation to the `menu-builder` agent to protect the orchestrator's context.

**Spawn `menu-builder` agent** (Sonnet) with:
- The CMS URL (from `.env` `CANVAS_SITE_URL`)
- The target menu structure from `docs/migration/plan.md` (extracted by site-analyzer in Phase 0-1)

The agent handles:
- Creating all items for `main`, `footer`, and `social-media` menus
- Creating the `social-media` menu if it does not exist yet (`ddev drush menu:create social-media "Social Media"` or via `/admin/structure/menu/add`)
- Verify-after-save for every item (navigates to menu list and confirms the item appears)
- Autocomplete dropdown handling (wait → check → dismiss)
- Reordering via weight dropdowns
- Cleaning up default footer menu items that come with Drupal CMS (e.g., "Home" link) if they don't match the source site
- Live site verification after all menus are configured

**After the agent completes**, check its report:
- If any items failed after retries, log them in `blocked.md`
- Verify menus on the live site yourself via Claude Chrome — the user should see the final result

Update `progress.md`.

### Phase 7: Page Content (content-composer agent)

**Wrapper discipline:** When restructuring page JSON composition (adding/removing wrapper components, changing section nesting), always check the source page's wrapper hierarchy CSS (max-width, padding, margin) from `css-audit.md` BEFORE making changes. Compare after. Never remove a wrapper component without understanding all the CSS properties it provides.

Build **every page** in the page inventory, one at a time. Each page is composed by the `content-composer` agent using VERBATIM text from the content files.

**For EACH page in the inventory, use the overlap pattern:**

1. **Spawn `content-composer` agent** (Opus) with:
   - The page name and target path
   - Path to `docs/migration/content/<page>.md` (verbatim text source — includes contextual metadata comments)
   - Path to `docs/migration/section-reference.md` (section-to-component mapping)
   - Path to `docs/migration/media-map.md` (image target_ids)
   - List of component.yml paths for components used on this page

2. The content-composer reads all inputs and composes JSON with EXACT text from the content file. It deploys the page via `cd canvas && npm run content -- create` or `-- update`.

3. **After `content-composer` finishes page N**, spawn `phase-verifier` for page N in background (`run_in_background: true`, mode `page-check`) with:
   - Source page URL
   - Target page URL (from `CANVAS_SITE_URL` in `.env`)
   - Path to `docs/migration/content/<page>.md` for text verification
   Then **immediately** spawn `content-composer` for page N+1 (don't wait for verifier).

4. Check `phase-verifier` results before marking page N as complete. If it reports text mismatches:
   - Resume the content-composer agent with specific fixes (exact text that's wrong and what it should be, from the content file)
   - Re-verify after fixes

5. Update `progress.md` after each page.

**The content-composer must NEVER generate text.** Every text value in the JSON must come from the content MD file. The agent prompt explicitly says: "You are a transcription agent. Copy text exactly. Do not improve, rephrase, or embellish."

**Important: Do NOT add footer components to page JSON.** The site renders a global footer automatically via page regions. Adding a footer component to the page creates a duplicate footer.

### Phase 8: Post-Migration Review (visual-verifier agent — Final Review)

This is a SECOND pass — Phase 7 already verified each page individually via `phase-verifier`. This phase uses the comprehensive `visual-verifier` agent for cross-page issues, responsive testing, link validation, regressions from later changes, and anything Phase 7 missed.

**Spawn `visual-verifier` agent** (Sonnet) with ALL pages to review, mode `Final Review`. The agent will:

1. For EACH section on EACH page:
   - Load the SOURCE section in Playwright (headless, fresh navigation)
   - Load the TARGET section in Claude Chrome (user is watching)
   - Compare visually and textually
   - Compare text against `docs/migration/content/<page>.md` verbatim reference
   - Report differences

2. Also check:
   - Responsive behavior at 375px for key sections (hero, cards, navigation)
   - All internal link targets resolve (not 404)
   - All images load (not broken)
   - Header/footer consistent across all pages
   - Cross-page navigation works

3. Save results to `docs/migration/post-migration.md` with per-section match/mismatch table

#### After Review

1. **Fix CRITICAL issues** found during the review — missing pages, broken navigation, wrong site name, text mismatches. These must be resolved before completing.
2. **Fix HIGH issues** — visual mismatches, missing sections, wrong styling, empty menus.
3. **Log remaining issues** in `blocked.md` with enough detail for manual fix.
4. Update `progress.md` — mark Phase 8 complete with final status summary.
5. Output a brief completion summary to the user.

## Section-by-Section Template

When composing components for a section, use this JSON structure as a starting point. Adjust component IDs and inputs based on the actual components needed:

```json
{
  "uuid": "<generated-uuid>",
  "component_id": "js.section",
  "inputs": {
    "width": "Normal",
    "background": "white"
  },
  "parent_uuid": null,
  "slot": null
}
```

With a child heading inside it:

```json
{
  "uuid": "<generated-uuid>",
  "component_id": "js.heading",
  "inputs": {
    "heading": "Section Title",
    "headingElement": "h2",
    "headingSize": "Large"
  },
  "parent_uuid": "<section-uuid>",
  "slot": "content"
}
```

## Troubleshooting: Component Rendering Issues

If the site shows errors or a component doesn't render after uploading, the issue is typically in the component's JavaScript or its data.

### Diagnosis Steps

1. **Check if the issue is site-wide or page-specific.** If all pages break, the issue is in a site-wide component (header, footer, global CSS). If only specific pages break, the issue is in that page's component data.
2. **Verify the API still works:** `cd canvas && npm run content -- list page`. If this returns data, the backend is fine — only the frontend renderer is broken.
3. **Run local validation:** `cd canvas && npm run canvas:validate`. If all components pass locally, the issue is likely in the page data or a runtime error in the component JavaScript (not a structural validation issue).
4. **Check the CMS directly:** Access `<CMS_URL>/homepage` (the CMS URL). If the CMS renders the page, the issue is in the Canvas frontend rendering.

### Common Causes

| Cause | Symptom | Fix |
|-------|---------|-----|
| **Component JS throws at runtime** | All pages break if it's header/footer; single page if page-specific | Add null guards to props that access `.src`, `.value`, etc. Destructure with defaults: `const { src } = image \|\| {}` |
| **Missing null guards on image props** | `TypeError: Cannot read properties of null (reading 'src')` | Always guard image prop access: `image?.src` or `const { src } = image \|\| {}` |
| **target_id as integer instead of string** | Image fails to resolve, component receives null | Use `"target_id": "31"` (string), not `"target_id": 31` (integer) |
| **link prop as object instead of string** | Component receives `{"uri": "/", "options": []}` instead of `"/"` | Link/URL props must be plain strings per `component.yml` `format: uri-reference` |
| **Component removed via Component Library UI** | Site breaks completely (known Canvas bug) | Never remove components via the library UI — use the Code component panel |
| **Global CSS breaks** | All pages break | Check `global.css` for invalid Tailwind directives (directives only work in `global.css`, not component CSS) |

### Recovery Steps

1. **If a specific component is suspect**, re-upload just that component: `cd canvas && npm run canvas:upload -- -c <name>`
2. **If the site is completely broken**, try re-uploading all components: `cd canvas && npm run canvas:upload`
3. **If re-uploading doesn't fix it**, the issue may be in the page data. Fetch the page (`cd canvas && npm run content -- get page <uuid>`), inspect the `components` array for malformed inputs, fix them, and update.
4. **If nothing works**, check `blocked.md` and consult Canvas documentation via `/canvas-docs-explorer known issues site unavailable`.

### Prevention

- **Always validate before uploading:** `cd canvas && npm run canvas:validate` catches structural issues. But it does NOT catch runtime JavaScript errors (like null pointer exceptions).
- **Add null guards** for all optional props that get destructured — especially image, link, and formatted text props.
- **Verify in Storybook first.** Build and preview in Storybook with realistic data AND with missing/empty data before uploading. If a component crashes in Storybook with a missing prop, it will crash the live site.
- **Upload one component at a time** when making changes. If the site breaks, you know exactly which component caused it. Use `cd canvas && npm run canvas:upload -- -c <name>`.
- **Check the site immediately after uploading.** Don't wait until Phase 7 to discover issues.

## Troubleshooting: Drupal CMS Configuration Issues

### Page Regions Not Rendering (No Header/Footer)

If pages show content but no header or footer, page regions are not configured.

**Fix:**
```bash
ddev drush config:set canvas.page_region.mercury.header status true -y
ddev drush config:set canvas.page_region.mercury.footer status true -y
ddev drush cr
```

Then verify by refreshing the site in Claude Chrome — header and footer should appear.

### JSON:API Read-Only Mode

If all write operations (POST, PATCH, DELETE) return HTTP 405 Method Not Allowed, JSON:API is in read-only mode.

**Fix:**
```bash
ddev drush config:set jsonapi.settings read_only false -y
ddev drush cr
```

### Permission Issues

If API requests return 403 Forbidden, check Drupal permissions.

**Fix:** Navigate to `/admin/people/permissions` in Claude Chrome and ensure the appropriate role has the needed permissions. For Canvas API access, the API client's role needs content CRUD permissions.

### jsonapi_menu_items Module Missing

If menu item endpoints return 404 or are not available in the types list, the module is not enabled.

**Fix:**
```bash
ddev drush en jsonapi_menu_items -y
ddev drush cr
```

Then verify: `cd canvas && npm run content -- list menu_items--main`

## Recovery: Disable-All Strategy

When the site breaks after component changes and you don't know which component caused it:

1. Set `status: false` in ALL component.yml files.
2. Upload all components: `cd canvas && npm run canvas:upload`
3. Verify the site loads again (disabled components aren't rendered, so the error should clear).
4. Re-enable components ONE AT A TIME:
   a. Set `status: true` for one component.
   b. Upload: `cd canvas && npm run canvas:upload -- -- -c <name>`
   c. Check the site — does it still load?
   d. If yes: that component is safe, move to the next.
   e. If broken: that component is the culprit.
5. Once identified, access the broken component in the Canvas Code Editor (`<CMS_URL>/canvas/code-editor/component/<name>`) to inspect its source — this works even when status is false.
6. Fix the issue, run `cd canvas && npm run canvas:ssr-test`, re-enable, re-upload.

## Handling Out-of-Scope Items

Some source site features cannot be replicated via Canvas components or JSON:API. When encountered:

1. **Webforms / contact forms** — Drupal CMS may have a webform module available. Check with `ddev drush pm:list | grep webform`. If not available, leave a placeholder component and log in `blocked.md`.
2. **Dynamic content** (search results, user-generated content, feeds) — skip and log.
3. **Third-party embeds** (maps, chat widgets, analytics) — skip and log.
4. **Server-side functionality** (redirects, access control) — skip and log.

Do not let out-of-scope items block progress on the rest of the migration.

## Canvas Documentation

**Use the `canvas-docs-explorer` skill to look up official Canvas documentation** whenever you need to understand platform behavior, verify admin paths, check for limitations, or troubleshoot unexpected errors.

Critical moments to consult the docs:

- **Before Phase 2** — fetch docs on `components`, `props`, `slots`, and `known-issues-and-limitations` to understand what the platform supports and what will break.
- **Before Phase 6** — fetch docs on `site-settings`, `menus`, `adding-links-menu`, and `content-workflows` to use the correct admin paths and avoid destructive actions.
- **When something fails** — before logging as blocked, search the docs. The answer may be a platform limitation with a documented workaround.
- **When touching components** — the known issues page documents a **component removal bug** that can break the entire site. Never remove components via the Component Library UI — use the Code component panel instead.

Invoke with: `/canvas-docs-explorer <query>`

## Canvas-Starter Reference

Canonical Canvas component development reference skills from the official canvas-starter are available at `.claude/reference/canvas-starter/`. Key references: `canvas-component-definition` for component contracts, `canvas-component-metadata` for component.yml schema, `canvas-component-upload` for upload error handling.
