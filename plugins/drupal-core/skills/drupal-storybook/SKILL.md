---
name: drupal-storybook
description: Storybook patterns for Drupal Single Directory Components (SDC). Covers atomic design hierarchy, story organization, naming conventions, controls matching component props, structural testing via stories, page stories as regression references, and asset handling.
---

# Creating and modifying stories for Drupal SDC

Stories prove your components work. They are living documentation, visual regression references, and the first place structural problems become visible. A story that renders correctly with realistic content gives confidence; a story that only works with placeholder text hides structural gaps.

Stories fall into a few categories:

## Component stories (Atomic Design Hierarchy)

Stories are organized by atomic design level:

| Level | Location | Examples |
|-------|----------|----------|
| Atoms | `stories/atoms/` | button, heading, text, image, logo, icon |
| Molecules | `stories/molecules/` | card, blockquote, breadcrumb, search-form |
| Organisms | `stories/organisms/` | hero, card-grid, two-column-text, stats-banner, header, footer, navigation |

- Naming convention: `<component-name>.stories.tsx` using `kebab-case`
- Story titles use the level as prefix: `Atoms/Button`, `Molecules/Card`, `Organisms/Hero`

Auto documentation should be used, and all parameter types must be explicitly defined with appropriate controls. Always cross-reference the story parameters with the SDC `*.component.yml` `props` and `slots`. See `references/sdc-component-yml.md` for the full schema.

Non-interactive tests (e.g. expects) can be added to component stories, but interactive tests that simulate user input MUST NOT be included in stories.

Both props and slots arguments MUST be either scalar values, an image object type, or a React/Twig fragment of public components. You must never use direct HTML markup in story arguments.

### Mapping SDC props to Storybook controls

Every prop defined in the component's `*.component.yml` should have a matching Storybook `argType`. Use the JSON Schema type to pick the right control:

| JSON Schema type | Storybook control |
|------------------|-------------------|
| `type: string` | `text` |
| `type: string` + `enum` | `select` or `radio` |
| `type: boolean` | `boolean` |
| `type: integer` / `type: number` | `number` |
| `type: array` | `object` (JSON editor) |
| `type: object` | `object` (JSON editor) |

For slots defined in `*.component.yml`, represent them as render-function args or children in JSX. Document which slot each arg maps to.

## Test stories

- Location: `stories/tests/`
- Naming convention: `<component-name>.stories.tsx` using `kebab-case`, although if a component has a large number of tests, they can be grouped using `<component-name>-<group>.stories.tsx`.

These are intended to provide automated tests for components and other UI elements.

Auto documentation MUST be disabled.

## Templates

- Location: `stories/templates/`
- Contains layout wrapper components that provide consistent page chrome (header, footer, navigation).
- Story title prefix: `Templates/`

## Page stories

- Location: `stories/pages/`
- Naming convention: `<page-name>.stories.tsx` using `kebab-case`.
- Story title prefix: `Pages/`

These provide an example of how a page could be built using components.

Autodocs must be disabled and the fullscreen layout must be used. There must only be one story per page.

A layout wrapper component from the templates stories should be used to ensure consistent wrapping of the page with header, footer, and navigation.

Both props and slots arguments MUST be either scalar values, an image object type, or a React/Twig fragment of public components. You must never use direct HTML markup.

## Assets

### Placeholder images

Placehold.co can be used to generate placeholder images for components:

```
{
   src: "https://placehold.co/800x600",
   alt: "Example image placeholder",
   width: 800,
   height: 600,
}
```

## Page Story Composition Rules

Page stories MUST only import and compose existing components.

### Allowed
- Import from your component library (e.g. `themes/custom/mytheme/components/<name>`)
- Pass props and compose together
- Define sample data objects (strings, image objects, arrays of scalars)

### NOT Allowed
- Define React components inline in the story file
- Use raw HTML elements (`<div>`, `<span>`, `<section>`) for layout
- Duplicate existing component code

If you need a wrapper `<div>`, find the existing component that provides that layout (e.g., a section component for width constraints, a grid component for columns). If none exists, create the SDC component first.

### Spacing Between Components

Control spacing between components using a spacing or layout component, NOT margins, padding, or wrapper divs.

```jsx
// Correct — use a layout component
<Hero title="About Us" />
<Section width="normal" content={<Text text="<p>Our story...</p>" />} />

// Wrong — raw HTML and className for spacing
<Hero title="About Us" />
<div className="mt-16">
  <Section width="normal" content={<Text text="<p>Our story...</p>" />} />
</div>
```

### Single-Story Hoisting

Page stories should export only ONE story (typically `Default`) with a `name` property matching the page title. This creates flat sidebar navigation instead of nested folders.

```tsx
export const Default: Story = {
  name: 'Home Page',
  render: () => (
    <PageWrapper>
      <Hero title="Welcome" />
      <Section width="normal" content={<Text text="<p>...</p>" />} />
    </PageWrapper>
  ),
};
```

## Page Stories as Regression References

Every key page should have a corresponding page story that serves as a visual regression reference.

- **Compose all components in the same order as the target page** -- hero, then content sections, then CTA, then footer. The story should mirror the page structure.
- **Use realistic content that matches the intended design.** Real headings, real body text, real image dimensions. Placeholder content hides structural problems -- if the footer story only shows `text: "Footer"` instead of 3 menu columns with social links, it will not catch a structurally inadequate footer component.
- **Page stories are regression tests.** If a component change breaks a page story, that is a signal -- not noise.

## Structural Testing via Stories

Stories are the first line of defense -- if a component crashes in Storybook, it will crash on the live site.

- **Create a story variant with NO props passed** (bare minimum render) -- this simulates server-side rendering with empty data. If it crashes, the component will crash the live site when rendered without data.
- **Create a story variant with FULL realistic content** -- this verifies all structural elements render. If the target footer has a logo, 3 menu columns, social links, and copyright, create a story variant with all of those populated.
- **Verify all structural elements render.** Columns should appear, menu items should list, slot children should display in their containers.
- **If only partial content renders in a story, it will be partial on the live site too.** A story is a truthful preview of component capability.
- If `npm run build-storybook` (Storybook static build) fails, fix before deploying.

### Real assets

Assets should be stored in a `stories/assets/` directory, in suitable subdirectories depending on the scope of the asset. An `index.ts` file must be created to export the assets with the correct image type. Real assets must never be directly imported in stories without their image type. The image type must include the correct dimensions and provide alt text.

## Example: SDC Component with Story

Given a Drupal SDC card component at `themes/custom/mytheme/components/card/`:

### card.component.yml

```yaml
name: Card
status: stable
props:
  type: object
  required:
    - title
  properties:
    title:
      type: string
      title: Card title
    description:
      type: string
      title: Card description
    image_url:
      type: string
      title: Image URL
slots:
  actions:
    title: Card actions
    description: Buttons or links at the bottom of the card.
```

### card.stories.tsx

```tsx
import type { Meta, StoryObj } from '@storybook/react';
import Card from './Card';

const meta: Meta<typeof Card> = {
  title: 'Molecules/Card',
  component: Card,
  tags: ['autodocs'],
  argTypes: {
    title: { control: 'text' },
    description: { control: 'text' },
    image_url: { control: 'text' },
  },
};

export default meta;
type Story = StoryObj<typeof Card>;

// Bare minimum — no props, verifies component does not crash with empty data.
export const Empty: Story = {};

// Full realistic content — verifies all structural elements render.
export const FullContent: Story = {
  args: {
    title: 'Annual Community Report',
    description: 'A detailed overview of our community impact this year.',
    image_url: 'https://placehold.co/400x300',
  },
};
```

See `references/sdc-component-yml.md` for the complete `*.component.yml` schema, including dependencies, libraryOverrides, and advanced prop patterns.

## Related Skills

- **drupal-sdc** -- Single Directory Components architecture, directory structure, Twig usage
- **drupal-frontend-expert** -- Twig templates, theming, CSS/JS libraries, Drupal.behaviors
