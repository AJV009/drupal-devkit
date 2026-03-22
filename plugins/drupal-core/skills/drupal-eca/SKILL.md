---
name: drupal-eca
description: Use when creating automated reactions to Drupal site events with ECA (Event-Condition-Action) workflows — covers component wiring, plugin discovery, and module management for content creation, form submissions, and user actions.
---

# Drupal ECA Workflow Management

**Source**: Converted from `ai_agents_eca` Drupal AI agent (`drupal.org/project/ai_agents`)
**Module**: [ECA](https://drupal.org/project/eca) (Event-Condition-Action)
**Requires**: `eca` base module plus submodules for specific event/action domains

## When This Skill Activates

Use this skill when working with ECA workflows in Drupal:
- Creating automated reactions to site events (content CRUD, form submissions, user actions)
- Building conditional workflow logic with branching and gateways
- Discovering available ECA plugins (events, conditions, actions)
- Managing ECA submodules and their capabilities
- Debugging or modifying existing ECA workflow models

---

## Core Concepts

An ECA workflow (model) consists of four types of components linked together:

- **Event**: The trigger -- what causes the workflow to run (e.g., "content entity is inserted", "form is submitted", "user logs in"). Each event has a plugin ID and configuration.
- **Condition**: A check that gates execution (e.g., "entity is of type article", "user has role editor"). Conditions are referenced by successors to make execution conditional.
- **Action**: Something that happens (e.g., "send email", "set field value", "display message", "redirect user"). Actions can chain to further actions via successors.
- **Gateway**: A routing point for branching logic. Each branch in a gateway can have its own condition.

---

## How Components Connect: Successors

Events, actions, and gateways have **successors** -- an array defining what runs next:

```json
"successors": [
  {"id": "action_1", "condition": ""},
  {"id": "action_2", "condition": "cond_1"}
]
```

- `id`: References another component (action or gateway) by its component_id.
- `condition`: References a condition component by its component_id, or empty string for unconditional execution.

Conditions do NOT have successors -- they are referenced FROM successors.

---

## ECA Submodules

ECA has submodules that provide events, conditions, and actions for different areas. Check which are enabled before creating workflows, and enable any required modules first.

| Module | Domain |
|---|---|
| `eca_content` | Content entity events (insert, update, delete, presave) |
| `eca_form` | Form events (alter, validate, submit) |
| `eca_user` | User events (login, logout, register) |
| `eca_workflow` | Content moderation/workflow transitions |
| `eca_views` | Views-related events and actions |
| `eca_base` | Basic conditions and actions (field values, tokens, logic) |
| `eca_misc` | Miscellaneous actions (redirects, messages, HTTP responses) |
| `eca_log` | Logging actions |
| `eca_render` | Render/display actions |
| `eca_cache` | Cache tag invalidation |
| `eca_config` | Configuration change events |
| `eca_queue` | Queue processing |
| `eca_endpoint` | Custom URL endpoints |
| `eca_access` | Access control |
| `eca_file` | File operation events |

---

## Tool Inventory

These are the 11 tools available for ECA workflow management:

| # | Tool | Operation | Description |
|---|---|---|---|
| 1 | `ListEcaModels` | Read | Lists all ECA workflow models with ID, label, status, and component counts |
| 2 | `GetEcaModel` | Read | Gets the complete configuration of an ECA model including all events, conditions, actions, gateways, and successor connections |
| 3 | `CreateEcaModel` | Write | Creates a new ECA workflow model -- empty or with full structure (events, conditions, actions, gateways as JSON) in one call |
| 4 | `DeleteEcaModel` | Write | Permanently deletes an ECA workflow model and all its components |
| 5 | `SetEcaModelStatus` | Write | Enables or disables an ECA workflow model (disabled models do not react to events) |
| 6 | `AddEcaComponent` | Write | Adds an event, condition, action, or gateway to an existing ECA model |
| 7 | `UpdateEcaComponent` | Write | Updates the configuration, label, or successors of an existing component (partial update -- only provided fields change) |
| 8 | `RemoveEcaComponent` | Write | Removes a component from an ECA model and cleans up all successor references |
| 9 | `SearchEcaPlugins` | Read | Searches available ECA plugins (events, conditions, or actions) by keyword to discover plugin IDs, labels, descriptions, and provider modules |
| 10 | `ListEcaModules` | Read | Lists all available ECA submodules with name, description, and enabled/disabled status |
| 11 | `EnableEcaModule` | Write | Enables an ECA submodule to make its events, conditions, and actions available (restricted to `eca*` modules only) |

---

## Workflow: Creating an ECA Model

### Step 1: Identify required modules

Check which ECA submodules are enabled. Enable any needed modules before creating workflows that use their plugins.

### Step 2: Discover plugins

Search for the right event, condition, and action plugin IDs:
- `plugin_type: "event"` + `search: "insert"` -- find content insert events
- `plugin_type: "condition"` + `search: "bundle"` -- find entity type/bundle conditions
- `plugin_type: "action"` + `search: "message"` -- find message actions

### Step 3: Plan the component IDs

Choose meaningful IDs for each component (e.g., `event_node_insert`, `cond_is_article`, `action_send_email`). These IDs are used in successor references.

### Step 4: Create the model

**Option A** -- Create complete model in one call with events, conditions, actions, and gateways JSON.

**Option B** -- Create empty model, then add components one by one.

### Step 5: Verify

Retrieve the model to verify the complete workflow structure.

---

## Common Event Plugin IDs

| Plugin ID | Description | Example Configuration |
|---|---|---|
| `content_entity:insert` | Entity created | `{"type": "node article"}` or `{"type": "node _all"}` |
| `content_entity:update` | Entity updated | `{"type": "node article"}` |
| `content_entity:delete` | Entity deleted | `{"type": "node _all"}` |
| `content_entity:presave` | Before entity save | `{"type": "node article"}` |
| `form:form_alter` | Form is being built | `{"form_id": "node_article_edit_form"}` |
| `form:form_submit` | Form submitted | `{"form_id": "node_article_edit_form"}` |
| `form:form_validate` | Form validation | `{"form_id": "node_article_edit_form"}` |

ECA event plugin IDs follow a compound format. Always use SearchEcaPlugins to find the exact ID -- the `content_entity` events have many variations.

## Common Condition Plugin IDs

| Plugin ID | Description | Example Configuration |
|---|---|---|
| `eca_entity_type_bundle` | Check entity type and bundle | `{"type": "node article", "negate": false}` |
| `eca_entity_field_value_empty` | Check if field is empty | `{"field_name": "field_name", "negate": false}` |
| `eca_scalar_comparison` | Compare two values | `{"left": "[entity:field_name]", "right": "expected_value", "operator": "=="}` |
| `eca_current_user_role` | Check current user's role | `{"role": "administrator"}` |
| `eca_entity_is_new` | Check if entity is new | `{}` |

## Common Action Plugin IDs

| Plugin ID | Description | Example Configuration |
|---|---|---|
| `action_message_action` | Display a status message | `{"message": "Hello [entity:title]"}` |
| `eca_set_field_value` | Set an entity field value | `{"field_name": "field_status", "field_value": "1", "save_entity": true}` |
| `eca_save_entity` | Save the current entity | `{"entity": ""}` |
| `eca_token_set_value` | Set a token value | `{"token_name": "my_token", "token_value": "some value"}` |
| `eca_write_log_message` | Log a message | `{"message": "Something happened", "severity": "info"}` |
| `eca_state_write` | Write to Drupal state | `{"key": "my_key", "value": "my_value"}` |
| `eca_redirect_response` | Redirect user | `{"url": "/some/path", "status": "302"}` |

---

## Example: Simple Workflow

"When an article is created, display a welcome message":

```json
{
  "events": {
    "event_1": {
      "plugin": "content_entity:insert",
      "label": "Article created",
      "configuration": {"type": "node article"},
      "successors": [{"id": "action_1", "condition": ""}]
    }
  },
  "actions": {
    "action_1": {
      "plugin": "action_message_action",
      "label": "Show welcome message",
      "configuration": {"message": "New article created: [entity:title]"},
      "successors": []
    }
  }
}
```

## Example: Conditional Branching

"When content is saved, if it's an article send a message, otherwise log it":

```json
{
  "events": {
    "event_1": {
      "plugin": "content_entity:insert",
      "label": "Content created",
      "configuration": {"type": "node _all"},
      "successors": [{"id": "gw_1", "condition": ""}]
    }
  },
  "conditions": {
    "cond_article": {
      "plugin": "eca_entity_type_bundle",
      "label": "Is article",
      "configuration": {"type": "node article", "negate": false}
    }
  },
  "gateways": {
    "gw_1": {
      "type": 0,
      "successors": [
        {"id": "action_msg", "condition": "cond_article"},
        {"id": "action_log", "condition": ""}
      ]
    }
  },
  "actions": {
    "action_msg": {
      "plugin": "action_message_action",
      "label": "Article message",
      "configuration": {"message": "Article created!"},
      "successors": []
    },
    "action_log": {
      "plugin": "eca_write_log_message",
      "label": "Log other",
      "configuration": {"message": "Non-article content created", "severity": "info"},
      "successors": []
    }
  }
}
```

## Example: Content Approval Workflow

"When content is submitted for review, notify editors by email, and if approved, publish automatically":

This requires multiple modules: `eca_content`, `eca_workflow`, `eca_misc`. The workflow would chain:

1. **Event**: Content moderation state change (submitted for review)
2. **Action**: Send email notification to editors
3. **Event**: Content moderation state change (approved)
4. **Action**: Set published status via `eca_set_field_value`

## Example: Automated Tagging

"Check content type on creation and assign default taxonomy terms based on bundle":

1. **Event**: `content_entity:insert` with `{"type": "node _all"}`
2. **Gateway**: Route to different actions based on bundle conditions
3. **Conditions**: `eca_entity_type_bundle` for each content type
4. **Actions**: `eca_set_field_value` to assign the appropriate term reference

---

## Token Syntax

ECA uses Drupal's token system for dynamic values in configurations:

- `[entity:title]` -- Current entity title
- `[entity:field_name]` -- Entity field value
- `[entity:nid]` -- Entity node ID
- `[current-user:name]` -- Current user's name
- `[current-user:mail]` -- Current user's email
- `[site:name]` -- Site name

---

## Best Practices

- Always search for plugins to verify plugin IDs exist before using them in workflows.
- Check enabled modules and enable required ones before creating workflows.
- Use meaningful component IDs that describe their purpose (e.g., `event_node_insert`, not `e1`).
- Verify the model after creating or modifying it to confirm the structure is correct.
- Keep workflows focused -- one workflow per automation concern.
- Use gateways for branching rather than multiple events.
- When removing components, successor references are cleaned up automatically by the removal tool.
- Disabled models do not react to events -- use status toggling for temporary deactivation.

---

## Example Prompts

### Viewing Configuration
- "List all ECA models on the site"
- "Show me the details of the content notification workflow"
- "What ECA modules are available?"

### Creating Workflows
- "Create an ECA workflow that sends an email notification when a new article is published"
- "Set up a workflow that automatically assigns a taxonomy term when content is created"
- "Create a workflow that logs a message whenever a user logs in"
- "Build an ECA model that sets a field value when a form is submitted"

### Managing Components
- "Add an email notification action to the content publish workflow"
- "Add a condition to check if the content type is 'article' before sending the notification"
- "Update the email action to include the node title in the subject line"
- "Remove the logging action from the user login workflow"

### Plugin Discovery
- "Search for ECA plugins related to email"
- "What event plugins are available for content entities?"
- "Find condition plugins for checking user roles"
- "What action plugins can modify field values?"

### Enabling and Disabling
- "Disable the test notification workflow"
- "Enable the content moderation ECA model"
- "Enable the ECA Content module for content entity events"

### Complex Workflows
- "Create a content approval workflow: when content is submitted for review, notify editors by email, and if approved, publish it automatically"
- "Set up an automated tagging workflow that checks the content type and assigns default tags based on the bundle"
