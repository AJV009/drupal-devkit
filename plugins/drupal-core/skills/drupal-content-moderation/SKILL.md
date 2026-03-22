---
name: drupal-content-moderation
description: Use when setting up editorial workflows, managing publishing states, or configuring content approval processes. Covers Drupal core Workflows and Content Moderation modules — states, transitions, and entity type/bundle attachments.
source:
  type: drupal-ai-agent
  module: ai_agents_content_moderation
  agent_id: content_moderation_manager
  repository: ai_agents_experimental_collection
---

# Drupal Content Moderation Workflows

Content moderation in Drupal uses the core Workflows and Content Moderation modules to define editorial processes for content. Every workflow consists of states, transitions, and entity type attachments.

## Key Concepts

- **Workflow**: A content moderation workflow defines the editorial process for content. Each workflow has states and transitions. Workflows are configuration entities with machine name IDs.
- **States**: Each state has an ID, label, and two critical flags: `published` (content is live and visible to anonymous users) and `default_revision` (this revision is the one loaded by default). The "Draft" and "Published" states are required and cannot be deleted.
- **Transitions**: Define allowed movements between states. Each transition has one or more `from_states` and a single `to_state`. Transitions control which state changes are permitted.
- **Entity Type Attachment**: Workflows are attached to entity type + bundle combinations (e.g. `node:article`, `node:page`, `media:image`). A bundle can only have one workflow at a time.

## Default Workflow Behavior

When a new content moderation workflow is created, it automatically receives:
- A "Draft" state (`draft`) -- not published, is default revision
- A "Published" state (`published`) -- published, is default revision
- A "Create New Draft" transition -- from Draft to Draft
- A "Publish" transition -- from Draft to Published

## State Flags

| Flag | Value | Meaning |
|------|-------|---------|
| `published` | `true` | Content in this state is visible to anonymous/public users |
| `published` | `false` | Content is hidden from public view |
| `default_revision` | `true` | This revision is the one loaded by default |
| `default_revision` | `false` | Only used for forward revisions (draft on top of published) |

## Common Custom States

| State | Published | Default Revision | Purpose |
|-------|-----------|-----------------|---------|
| Review / In Review | `false` | `true` | Content awaiting editorial review |
| Archived | `false` | `true` | Content removed from public view |
| Needs Work | `false` | `true` | Content sent back for revisions |
| Approved | `false` | `true` | Content approved but not yet live |

## Common Workflow Patterns

1. **Simple Editorial**: Draft -> Published -> Archived
2. **Review Workflow**: Draft -> In Review -> Published -> Archived
3. **Multi-stage Review**: Draft -> Review -> Approved -> Published -> Archived

## State and Transition Naming

- State and transition IDs must be lowercase with underscores (machine names), e.g. `in_review`, `needs_work`.
- Labels are human-readable, e.g. "In Review", "Needs Work".
- The `from_states` parameter for transitions accepts a JSON array, e.g. `["draft", "review"]`.

## Tool Inventory

| # | Tool | Operation | Description |
|---|------|-----------|-------------|
| 1 | `list_workflows` | Read | Lists all content moderation workflows with their states and transitions summary. |
| 2 | `get_workflow` | Read | Gets full details of a workflow including states (with published/default_revision flags and weights), transitions (with from/to states and weights), and attached entity types/bundles. |
| 3 | `create_workflow` | Write | Creates a new content moderation workflow with a given ID and label. The workflow is created with default Draft and Published states. |
| 4 | `delete_workflow` | Write | Deletes a content moderation workflow. The workflow must not be attached to any entity types -- detach all entity types first. |
| 5 | `add_state` | Write | Adds a new state to a workflow with `published` and `default_revision` flags. |
| 6 | `update_state` | Write | Updates the label, weight, `published`, or `default_revision` flags of an existing state. |
| 7 | `delete_state` | Write | Deletes a state from a workflow. Cannot delete required states (`draft` or `published`). |
| 8 | `add_transition` | Write | Adds a new transition specifying `from_states` (JSON array) and `to_state`. |
| 9 | `update_transition` | Write | Updates the label, weight, or `from_states` of an existing transition. |
| 10 | `delete_transition` | Write | Deletes a transition from a workflow. |
| 11 | `attach_entity_type` | Write | Attaches a workflow to an entity type and bundle combination (e.g. `node:article`). |
| 12 | `detach_entity_type` | Write | Removes a workflow from an entity type and bundle combination. |

## Best Practices

- Always verify a workflow exists before modifying its states or transitions.
- Use `list_workflows` first to see available workflows.
- Use `get_workflow` to inspect full details before making changes.
- When adding custom states, consider whether content should be published and/or the default revision.
- When adding transitions, ensure all necessary from-state paths exist so editors are not stuck in dead-end states.
- Detach all entity types before deleting a workflow.
- A bundle can only belong to one workflow at a time -- attaching a new workflow implicitly detaches the old one.

## Example Workflows

### View existing workflows

```
List all content moderation workflows
```
```
Show me the editorial workflow configuration
```
```
What states and transitions are in the default workflow?
```

### Create an editorial review workflow

```
Create an editorial workflow with Draft, In Review, and Published states
```

Step-by-step breakdown:
1. `create_workflow` with `id: editorial` and `label: Editorial`
2. `add_state` with `state_id: in_review`, `label: In Review`, `published: false`, `default_revision: true`
3. `add_transition` with `transition_id: submit_for_review`, `label: Submit for Review`, `from_states: ["draft"]`, `to_state: in_review`
4. `add_transition` with `transition_id: publish`, update from_states to include `in_review`
5. `add_transition` with `transition_id: send_back`, `label: Send Back to Draft`, `from_states: ["in_review"]`, `to_state: draft`

### Set up a multi-stage approval workflow

```
Create a multi-stage workflow with Draft, Editorial Review, Legal Review, and Published
```

### Manage states

```
Add an 'Archived' state to the editorial workflow
```
```
Add a 'Needs Revision' state that is not published
```
```
Update the 'In Review' state label to 'Under Editorial Review'
```
```
Remove the 'Pending' state from the workflow
```

### Manage transitions

```
Add a transition from Draft to In Review called 'Submit for Review'
```
```
Allow editors to move content from In Review back to Draft
```
```
Add a 'Publish' transition from In Review to Published
```
```
Remove the direct Draft to Published transition
```

### Attach workflows to content

```
Attach the editorial workflow to the article content type
```
```
Apply the approval workflow to both articles and pages
```
```
Detach the workflow from the blog post content type
```

### Complete setup in a single request

```
Set up a full editorial workflow for articles with Draft, Review, Published, and Archived states with appropriate transitions
```
```
Create a simple publish/unpublish workflow and attach it to all content types
```

## Drupal Permissions

Content moderation workflow management requires one of:
- `administer content moderation via agent`
- `administer workflows`
