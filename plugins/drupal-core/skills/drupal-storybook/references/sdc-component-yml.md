# Drupal SDC `*.component.yml` Schema Reference

The `*.component.yml` file is the schema definition for a Single Directory Component (SDC) in Drupal core (stable since 10.3). It describes metadata, props (via JSON Schema), slots, dependencies, and library overrides.

This reference is for story authors who need to map SDC component definitions to Storybook controls and args.

## File location

Every SDC lives in its own directory under `components/` in a theme or module:

```
themes/custom/mytheme/components/hero/
  hero.component.yml    # Schema definition (required)
  hero.html.twig        # Twig template (required)
  hero.css              # Styles (optional, auto-loaded)
  hero.js               # JavaScript (optional, auto-loaded)
```

The directory name is the component machine name. All files must share that name.

## Full schema

```yaml
# Required: Human-readable name.
name: Hero

# Optional but recommended: Component stability.
# Values: stable | experimental | deprecated | obsolete
status: stable

# Optional: Human-readable description.
description: A full-width hero banner with heading, subheading, image, and call-to-action.

# Optional: Group for organizing components in documentation.
group: Layout

# Props definition using JSON Schema (draft 2020-12 subset).
props:
  type: object
  required:
    - heading
  properties:
    heading:
      type: string
      title: Heading
      description: The main heading text.
    subheading:
      type: string
      title: Subheading
      description: Optional subheading displayed below the heading.
    image_url:
      type: string
      title: Background image URL
      description: URL of the hero background image.
    cta_label:
      type: string
      title: CTA button label
    cta_url:
      type: string
      title: CTA button URL
    alignment:
      type: string
      title: Content alignment
      enum:
        - left
        - center
        - right
      default: center
    overlay_opacity:
      type: number
      title: Overlay opacity
      description: Value between 0 and 1 controlling the dark overlay.
      default: 0.5

# Slots: regions where other Twig content or components can be injected.
slots:
  content:
    title: Additional content
    description: Optional rich content displayed below the heading area.
  actions:
    title: Action buttons
    description: One or more CTA buttons or links.

# Library overrides: customize the auto-generated library for this component.
libraryOverrides:
  css:
    component:
      hero.css:
        weight: -1
  dependencies:
    - core/drupal
    - core/once
    - mytheme/global

# Third-party settings (optional, for integrations).
third_party_settings: {}
```

## Props: JSON Schema patterns

### Scalar types

```yaml
props:
  type: object
  properties:
    label:
      type: string
      title: Label
    count:
      type: integer
      title: Item count
      default: 0
    ratio:
      type: number
      title: Aspect ratio
    visible:
      type: boolean
      title: Visible
      default: true
```

### Enums (select / radio in Storybook)

```yaml
    variant:
      type: string
      title: Variant
      enum:
        - primary
        - secondary
        - outline
      default: primary
```

### Arrays

```yaml
    items:
      type: array
      title: Menu items
      items:
        type: object
        properties:
          label:
            type: string
          url:
            type: string
```

### Nested objects

```yaml
    image:
      type: object
      title: Image
      properties:
        src:
          type: string
        alt:
          type: string
        width:
          type: integer
        height:
          type: integer
```

### Required props

List required property names at the `props` level:

```yaml
props:
  type: object
  required:
    - heading
    - image_url
  properties:
    heading:
      type: string
    image_url:
      type: string
    description:
      type: string
```

Properties not in the `required` list are optional. Stories should test both with and without optional props.

## Slots

Slots are named Twig blocks that accept injected content. They are defined separately from props.

```yaml
slots:
  content:
    title: Main content
    description: The primary content area.
  sidebar:
    title: Sidebar
    description: Optional sidebar content.
```

In the Twig template, each slot maps to a `{% block %}`:

```twig
{# hero.html.twig #}
<section class="hero" style="background-image: url('{{ image_url }}');">
  <div class="hero__overlay" style="opacity: {{ overlay_opacity }}"></div>
  <div class="hero__inner hero__inner--{{ alignment }}">
    <h1 class="hero__heading">{{ heading }}</h1>
    {% if subheading %}
      <p class="hero__subheading">{{ subheading }}</p>
    {% endif %}
    <div class="hero__content">
      {% block content %}{% endblock %}
    </div>
    <div class="hero__actions">
      {% block actions %}
        {% if cta_label and cta_url %}
          <a href="{{ cta_url }}" class="hero__cta">{{ cta_label }}</a>
        {% endif %}
      {% endblock %}
    </div>
  </div>
</section>
```

In stories, slots are typically represented as children or render functions depending on the Storybook integration used.

## libraryOverrides

By default, Drupal auto-generates a library for each SDC that includes any `.css` and `.js` files in the component directory. Use `libraryOverrides` to customize this behavior.

### Adding dependencies

```yaml
libraryOverrides:
  dependencies:
    - core/drupal
    - core/once
    - mytheme/global
```

### Adjusting CSS weight

```yaml
libraryOverrides:
  css:
    component:
      card.css:
        weight: -1
```

### Adding external JS

```yaml
libraryOverrides:
  js:
    https://cdn.example.com/lib.js:
      type: external
      minified: true
```

The structure mirrors Drupal's `*.libraries.yml` format.

## Status values

| Status | Meaning |
|--------|---------|
| `stable` | Production-ready, API will not change without deprecation |
| `experimental` | May change between minor releases |
| `deprecated` | Scheduled for removal, migrate to replacement |
| `obsolete` | Do not use |

## Complete example: Card component

### Directory structure

```
themes/custom/mytheme/components/card/
  card.component.yml
  card.html.twig
  card.css
```

### card.component.yml

```yaml
name: Card
status: stable
description: A content card with image, title, body text, and action slot.

props:
  type: object
  required:
    - title
  properties:
    title:
      type: string
      title: Card title
      description: The card heading.
    body:
      type: string
      title: Body text
      description: Short description or summary.
    image:
      type: object
      title: Card image
      properties:
        src:
          type: string
          title: Image URL
        alt:
          type: string
          title: Alt text
        width:
          type: integer
        height:
          type: integer
    variant:
      type: string
      title: Card variant
      enum:
        - default
        - featured
        - minimal
      default: default

slots:
  actions:
    title: Card actions
    description: Buttons or links displayed at the bottom of the card.

libraryOverrides:
  dependencies:
    - core/drupal
```

### card.html.twig

```twig
<article {{ attributes.addClass('card', 'card--' ~ variant) }}>
  {% if image.src %}
    <div class="card__media">
      <img src="{{ image.src }}" alt="{{ image.alt|default('') }}" width="{{ image.width }}" height="{{ image.height }}" loading="lazy">
    </div>
  {% endif %}
  <div class="card__body">
    <h3 class="card__title">{{ title }}</h3>
    {% if body %}
      <p class="card__text">{{ body }}</p>
    {% endif %}
    {% block actions %}{% endblock %}
  </div>
</article>
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
    title: { control: 'text', description: 'The card heading' },
    body: { control: 'text', description: 'Short description or summary' },
    image: { control: 'object', description: 'Card image with src, alt, width, height' },
    variant: {
      control: 'select',
      options: ['default', 'featured', 'minimal'],
      description: 'Card variant',
    },
  },
};

export default meta;
type Story = StoryObj<typeof Card>;

// No props — verifies component renders safely with empty data.
export const Empty: Story = {};

// Full content — verifies all structural elements render.
export const FullContent: Story = {
  args: {
    title: 'Community Impact Report 2025',
    body: 'Our annual report highlights the key achievements and milestones from the past year.',
    image: {
      src: 'https://placehold.co/400x300',
      alt: 'Community gathering photo',
      width: 400,
      height: 300,
    },
    variant: 'default',
  },
};

// Featured variant.
export const Featured: Story = {
  args: {
    ...FullContent.args,
    variant: 'featured',
  },
};
```

## Mapping summary: component.yml to Storybook

| `*.component.yml` | Storybook equivalent |
|--------------------|----------------------|
| `name` | `meta.title` (with atomic design prefix) |
| `description` | `meta.parameters.docs.description.component` |
| `props.properties.<name>` | `meta.argTypes.<name>` + `Story.args.<name>` |
| `props.properties.<name>.type: string` | `argTypes: { control: 'text' }` |
| `props.properties.<name>.enum` | `argTypes: { control: 'select', options: [...] }` |
| `props.properties.<name>.type: boolean` | `argTypes: { control: 'boolean' }` |
| `props.properties.<name>.type: integer` | `argTypes: { control: 'number' }` |
| `props.properties.<name>.type: object` | `argTypes: { control: 'object' }` |
| `props.properties.<name>.type: array` | `argTypes: { control: 'object' }` |
| `props.properties.<name>.default` | `args: { <name>: <default> }` in default story |
| `props.required` | Mark in argType description; test both with and without |
| `slots.<name>` | Render function arg or JSX children |
| `status` | `meta.parameters.status.type` (with storybook-addon-status) |
