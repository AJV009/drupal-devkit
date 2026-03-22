---
name: drupal-visual-regression
description: Visual regression testing patterns for Drupal using Playwright screenshots and BackstopJS. Covers baseline capture, multi-viewport comparison, Drupal-specific concerns (toolbar masking, cache timing, status messages), CI integration, and review workflows.
---

# Drupal Visual Regression Testing

Catch unintended UI changes by comparing screenshots before and after code changes. Covers Playwright-based testing, BackstopJS workflows, Drupal-specific pitfalls, and CI integration.

## Playwright-Based Visual Testing

### Baseline Capture and Snapshot Comparison

Capture baselines with `page.screenshot()` and compare with `toMatchSnapshot()`. Playwright stores references in a `__snapshots__` directory. On subsequent runs, new screenshots are pixel-compared; failures produce expected, actual, and diff images.

```typescript
import { test, expect } from '@playwright/test';

test('homepage visual regression', async ({ page }) => {
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(1000); // Wait for Drupal JS behaviors and lazy images

  const screenshot = await page.screenshot({ fullPage: true });
  expect(screenshot).toMatchSnapshot('homepage.png', {
    maxDiffPixelRatio: 0.01,
  });
});
```

### Multi-Viewport Testing

Test across breakpoints matching your theme's responsive design. Adjust widths to match your `breakpoints.yml`:

```typescript
const VIEWPORTS = [
  { name: 'mobile', width: 320, height: 812 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'desktop-small', width: 1024, height: 768 },
  { name: 'desktop', width: 1280, height: 900 },
  { name: 'desktop-wide', width: 1440, height: 900 },
];

for (const vp of VIEWPORTS) {
  test(`homepage at ${vp.name} (${vp.width}px)`, async ({ browser }) => {
    const context = await browser.newContext({ viewport: { width: vp.width, height: vp.height } });
    const page = await context.newPage();
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    const screenshot = await page.screenshot({ fullPage: true });
    expect(screenshot).toMatchSnapshot(`homepage-${vp.name}.png`);
    await context.close();
  });
}
```

For mobile viewports, verify: stack direction changes, hidden/shown elements, text truncation, and touch targets (minimum 44x44px).

### Masking Dynamic Content

Drupal pages contain dynamic content (dates, contextual links, status messages) that causes false positives. Use Playwright's `mask` option or CSS injection:

```typescript
// Option 1: mask locators (pink boxes replace matched elements)
const screenshot = await page.screenshot({
  fullPage: true,
  mask: [page.locator('.messages--status'), page.locator('time'), page.locator('.contextual')],
});

// Option 2: CSS injection for finer control
await page.addStyleTag({
  content: `.node__submitted, .field--name-changed, time, .contextual,
            .messages--status { visibility: hidden !important; }`,
});
```

### Per-Section Screenshots

Full-page screenshots catch global regressions but make it hard to pinpoint which section changed. Section-level screenshots isolate failures and produce more maintainable baselines:

```typescript
const SECTIONS = [
  { name: 'hero', selector: '.block-hero, .paragraph--type--hero' },
  { name: 'cards', selector: '.view-cards, .paragraph--type--card-grid' },
  { name: 'footer', selector: 'footer, .region-footer' },
];

for (const section of SECTIONS) {
  test(`homepage section: ${section.name}`, async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    const el = page.locator(section.selector).first();
    if (await el.isVisible()) {
      expect(await el.screenshot()).toMatchSnapshot(`homepage-${section.name}.png`);
    }
  });
}
```

Combine per-section with per-viewport for comprehensive coverage.

## BackstopJS (Drupal Community Standard)

BackstopJS is widely used in the Drupal community. It uses headless Chrome and provides a built-in HTML report viewer.

### Configuration and Workflow

```json
{
  "id": "drupal_project",
  "viewports": [
    { "label": "mobile", "width": 320, "height": 812 },
    { "label": "tablet", "width": 768, "height": 1024 },
    { "label": "desktop", "width": 1280, "height": 900 },
    { "label": "wide", "width": 1440, "height": 900 }
  ],
  "scenarios": [
    {
      "label": "Homepage",
      "url": "https://mysite.ddev.site",
      "delay": 1500,
      "removeSelectors": ["#toolbar-administration", ".contextual-region > .contextual", ".messages--status"],
      "misMatchThreshold": 0.1
    }
  ],
  "engine": "playwright",
  "engineOptions": { "args": ["--no-sandbox"] },
  "paths": {
    "bitmaps_reference": "backstop_data/bitmaps_reference",
    "bitmaps_test": "backstop_data/bitmaps_test",
    "html_report": "backstop_data/html_report"
  },
  "report": ["browser"]
}
```

```bash
backstop reference   # Capture baselines on stable branch
backstop test        # Compare on feature branch
backstop approve     # Accept intentional changes as new baselines
```

### Docker-Based Execution

Run in Docker to eliminate rendering differences between machines and CI. Use `--network host` to access DDEV or other local environments:

```bash
docker run --rm --network host -v $(pwd):/src backstopjs/backstopjs reference
docker run --rm --network host -v $(pwd):/src backstopjs/backstopjs test
```

## Drupal-Specific Concerns

### Admin Toolbar

The admin toolbar shifts page content and appears in authenticated screenshots. Strategies:

1. **Test as anonymous** (simplest) — do not log in before capturing.
2. **CSS injection** — hide toolbar and reset body padding:
   ```typescript
   await page.addStyleTag({ content: `
     #toolbar-administration, .toolbar-oriented { display: none !important; }
     body.toolbar-fixed { padding-top: 0 !important; }
   `});
   ```
3. **`?_wrapper_format=drupal_modal`** — loads content without full page chrome (toolbar, admin menus).

### Status Messages

Transient `div.messages` elements cause false positives. Always remove them before capture via CSS injection in Playwright or `removeSelectors: [".messages"]` in BackstopJS.

### Cache Variations

Drupal's render cache, page cache, and dynamic page cache cause inconsistent screenshots. Always run `drush cr` before both baseline capture and test runs. Optionally warm page cache afterward with `curl -s -o /dev/null <url>` for key pages.

### Responsive Breakpoints Matching `breakpoints.yml`

Align visual regression viewports with your theme's `breakpoints.yml`. Test at each breakpoint width and one pixel below to catch edge cases. For example, if your theme defines breakpoints at 768px, 1024px, and 1440px, test at: 320px (mobile), 767px (below tablet), 768px (tablet), 1023px (below desktop), 1024px (desktop), 1440px (wide).

### Authenticated vs Anonymous

Drupal renders differently by role: toolbar, contextual links, unpublished content, block visibility conditions, edit tabs. Run tests for both sessions and name snapshots distinctly (e.g., `homepage-anon.png`, `homepage-auth.png`). For authenticated tests, log in via the Drupal login form then hide the toolbar via CSS injection before capture.

## Workflow

### 1. Capture Baselines on Stable Branch

```bash
git checkout main && drush cr
npx playwright test --update-snapshots   # or: backstop reference
```

### 2. Run Comparison on Feature Branch

```bash
git checkout feature/my-changes && drush cr
npx playwright test   # or: backstop test
```

### 3. Review Diffs

Playwright outputs diff images in `test-results/`. BackstopJS generates `backstop_data/html_report/index.html`. For each failure, determine: intentional change, regression, or false positive.

### 4. Approve Intentional Changes

```bash
npx playwright test --update-snapshots   # or: backstop approve
```

Commit updated baselines alongside the code changes.

### 5. Storybook Component Baselines

If the project uses Storybook, capture component-level baselines from isolated views. This catches component regressions independently of Drupal page context:

```typescript
test('card component regression', async ({ page }) => {
  await page.goto('http://localhost:6006/iframe.html?id=components-card--default&viewMode=story');
  await page.waitForTimeout(1000);
  expect(await page.screenshot()).toMatchSnapshot('component-card-default.png');
});
```

## CI Integration

### GitHub Actions

```yaml
name: Visual Regression
on:
  pull_request:
    branches: [main, develop]
jobs:
  visual-regression:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env: { MYSQL_ROOT_PASSWORD: root, MYSQL_DATABASE: drupal }
        ports: ['3306:3306']
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: shivammathur/setup-php@v2
        with: { php-version: '8.3', extensions: 'gd, pdo_mysql' }
      - run: composer install --no-interaction && drush site:install --existing-config -y && drush cr
      - run: npx playwright install --with-deps chromium
      - uses: actions/cache@v4
        with:
          path: tests/visual/__snapshots__
          key: visual-baselines-${{ github.base_ref }}-${{ hashFiles('**/*.twig', '**/*.css') }}
          restore-keys: visual-baselines-${{ github.base_ref }}-
      - run: npx playwright test tests/visual/
        env: { BASE_URL: 'http://localhost:8080' }
      - uses: actions/upload-artifact@v4
        if: failure()
        with: { name: visual-diffs, path: test-results/, retention-days: 14 }
```

### GitLab CI

```yaml
visual-regression:
  stage: test
  image: mcr.microsoft.com/playwright:v1.48.0-jammy
  services: [mysql:8.0]
  variables: { MYSQL_ROOT_PASSWORD: root, MYSQL_DATABASE: drupal }
  before_script:
    - composer install --no-interaction && drush site:install --existing-config -y && drush cr
  script: npx playwright test tests/visual/
  artifacts:
    when: on_failure
    paths: [test-results/]
    expire_in: 2 weeks
  cache:
    key: visual-baselines-${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}
    paths: [tests/visual/__snapshots__/]
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
```

### Baseline Storage

**In git:** Simple, version-controlled, reviewable in PRs. Downside: repo size grows. Best for moderate page/viewport counts. **As CI artifacts (S3/GCS):** Reduces repo bloat, baselines pinned to branch/commit. Best for large projects. Start with git; move to artifact storage when snapshots exceed 100MB.

### Failing PRs on Visual Changes

Both Playwright and BackstopJS exit non-zero on mismatches, failing CI by default. Require the visual regression job to pass in branch protection rules (GitHub) or merge request approvals (GitLab).

## Severity Classification

Classify visual regression failures to prioritize review and fixes:

| Severity | Criteria | Action |
|----------|----------|--------|
| **Critical** | Layout broken (columns collapsed, sections missing), color scheme inverted (dark/light), content invisible or unreadable, entire component missing | Block merge. Fix immediately. |
| **High** | Noticeable color difference, font size/weight wrong, spacing >8px off, wrong border/shadow, responsive breakpoint incorrect, image wrong size or aspect ratio | Block merge. Fix before release. |
| **Medium** | Minor spacing difference (4-8px), subtle font rendering variation, minor border-radius difference, slight alignment shift | Log in review. Fix if time permits. |
| **Low** | Sub-pixel rendering, anti-aliasing differences, browser-specific font smoothing, 1-2px rounding shifts | Note and skip. Typically false positives. |

For automated triage, set `maxDiffPixelRatio` thresholds: >5% is likely critical/high, 1-5% medium, <1% typically low or false positive.
