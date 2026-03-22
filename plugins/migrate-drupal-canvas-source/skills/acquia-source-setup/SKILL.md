---
name: acquia-source-setup
description: Connecting a Canvas component project to Acquia Source, configuring OAuth API clients, uploading components, troubleshooting authentication errors (401, client auth failed, no components found), and managing .env configuration
---

# Acquia Source Setup & Connection

This skill covers connecting a Canvas Storybook AI project to an Acquia Source
instance for component uploads and content management. Use this when setting up
a new project, debugging upload/auth failures, or onboarding a new site.

## Architecture Overview

The system uses two separate APIs, each requiring different OAuth configuration:

| API              | Base Path                    | Purpose                      | CLI Command        |
| ---------------- | ---------------------------- | ---------------------------- | ------------------ |
| Canvas REST API  | `/canvas/api/v0/`            | Upload/manage components     | `canvas:upload`    |
| JSON:API         | `/<prefix>` (e.g., `/api`)   | Content management (pages)   | `content`          |

Both APIs authenticate via OAuth 2.0 Client Credentials flow through the
`/oauth/token` endpoint on the CMS URL.

### Canvas REST API Endpoints

| Endpoint                                     | Method     | Purpose                  |
| -------------------------------------------- | ---------- | ------------------------ |
| `/canvas/api/v0/config/js_component`         | GET / POST | List / create components |
| `/canvas/api/v0/config/js_component/<name>`  | GET / PUT  | Get / update a component |
| `/canvas/api/v0/config/asset_library/global` | GET / PUT  | Get / update global CSS  |

### JSON:API Endpoints

| Endpoint                  | Method     | Purpose              |
| ------------------------- | ---------- | -------------------- |
| `/<prefix>/page`          | GET / POST | List / create pages  |
| `/<prefix>/node--article` | GET / POST | Articles             |
| `/<prefix>/media--image`  | GET / POST | Media images         |

## Site URLs

Each Acquia Source site has two URLs:

- **CMS URL**: `https://<ID>.cms.acquia.site` — Used for API access, admin
  panel, and all `.env` configuration
- **Public URL**: `https://<name>.acquia.site` — The live public-facing site

Always use the **CMS URL** for `CANVAS_SITE_URL` in `.env`.

## Step 1: Configure OAuth API Client in Acquia Source

Navigate to the admin panel:

```
https://<ID>.cms.acquia.site/admin/config/services/api-clients
```

Create or edit an API client with these **required** settings:

### Basic Settings

| Field        | Value                                    | Notes                        |
| ------------ | ---------------------------------------- | ---------------------------- |
| Label        | Any name (e.g., "Canvas CLI")            | Display name only            |
| Machine name | e.g., `default_client`                   | Becomes `CANVAS_CLIENT_ID`   |
| Secret       | e.g., `secret`                           | Becomes `CANVAS_CLIENT_SECRET` |

### Grant Types

Enable **Client Credentials** grant type. This is essential — without it, the
CLI cannot authenticate.

### Scopes

Add **all three** scopes:

| Scope                  | Required For                  |
| ---------------------- | ----------------------------- |
| `canvas:asset_library` | Uploading global CSS          |
| `canvas:js_component`  | Uploading components          |
| `member`               | Authenticated API access      |

### Client Credentials Settings (CRITICAL)

Under the **"Client Credentials settings"** section of the API client form:

- **User**: Assign an existing Drupal user (e.g., your admin account)

This is the user context under which API operations execute. The User field is
an autocomplete — start typing the username and select from the dropdown.

**This is the most commonly missed step.** Without a user assigned, the Canvas
REST API returns 401 even though the OAuth token itself is valid. See
Troubleshooting below.

## Step 2: Check JSON:API Prefix

Check your JSON:API configuration at:

```
https://<ID>.cms.acquia.site/admin/config/services/jsonapi
```

Note the **URL prefix**. Acquia Source sites often use `api` instead of the
Drupal default `jsonapi`.

## Step 3: Create the `.env` File

Copy `.env.example` to `.env` and fill in the values:

```env
# Base URL — must be the CMS URL, not the public URL
CANVAS_SITE_URL=https://<ID>.cms.acquia.site

# JSON:API prefix — check admin/config/services/jsonapi
CANVAS_JSONAPI_PREFIX=api

# OAuth credentials from Step 1
CANVAS_CLIENT_ID=default_client
CANVAS_CLIENT_SECRET=secret

# Component source directory
CANVAS_COMPONENT_DIR=./src/components

# Debug logging
CANVAS_VERBOSE=false
```

### Full Environment Variable Reference

| Variable                | Required | Default                                    | Description                         |
| ----------------------- | -------- | ------------------------------------------ | ----------------------------------- |
| `CANVAS_SITE_URL`       | Yes      | —                                          | CMS base URL                        |
| `CANVAS_JSONAPI_PREFIX` | No       | `jsonapi`                                  | JSON:API URL prefix                 |
| `CANVAS_CLIENT_ID`      | Yes      | —                                          | OAuth client machine name           |
| `CANVAS_CLIENT_SECRET`  | Yes      | —                                          | OAuth client secret                 |
| `CANVAS_COMPONENT_DIR`  | No       | `./components`                             | Path to component source directory  |
| `CANVAS_VERBOSE`        | No       | `false`                                    | Enable verbose CLI logging          |
| `CANVAS_SCOPE`          | No       | `canvas:js_component canvas:asset_library` | Custom OAuth scopes                 |
| `CONTENT_NO_AUTH`       | No       | `false`                                    | Disable auth for content scripts    |
| `CONTENT_OAUTH_SCOPE`   | No       | —                                          | Custom scope for content API        |

## Step 4: Validate and Upload

```bash
# Validate component structure
npm run canvas:validate

# Validate a specific component
npm run canvas:validate -- -c heading

# Upload all components
npm run canvas:upload

# Upload a specific component
npm run canvas:upload -- -c heading
```

Successful upload output:

```
22 succeeded, 0 failed
Components and global CSS uploaded successfully
```

## Step 5: Update vite.config.js

Update the `siteUrl` in `vite.config.js` to match your CMS URL:

```js
drupalCanvas({
  componentDir: './src/components',
  siteUrl: 'https://<ID>.cms.acquia.site',
  jsonapiPrefix: 'api',
}),
```

## Step 6: Verify Components

Verify each component in the Canvas Code Editor:

```
<CMS_URL>/canvas/code-editor/component/<component_name>
```

Check that props, source code, and preview render correctly. Components should
also be available in the Canvas page builder in the admin panel under the
component library.

## Troubleshooting

### Error: "No local components found in ./components"

**Cause**: `CANVAS_COMPONENT_DIR` is not set or points to the wrong directory.

**Fix**: Add to `.env`:

```env
CANVAS_COMPONENT_DIR=./src/components
```

The default is `./components`, but this project uses `./src/components`.

### Error: "Client authentication failed"

**Cause**: Wrong `CANVAS_CLIENT_ID` or `CANVAS_CLIENT_SECRET`.

**Fix**: Check the API client's **machine name** (not the label) in the admin
panel at `/admin/config/services/api-clients`. The machine name is the value
you need for `CANVAS_CLIENT_ID`.

Common mistake: using the label (e.g., "Test Client") instead of the machine
name (e.g., `default_client`), or using `cli` when the actual machine name is
different.

### Error: "You must be logged in to access this resource" (401)

This is the most common and confusing error. The OAuth token is valid, but the
Canvas REST API still rejects it. This happens when the API client is missing
one or more of three required settings.

**Diagnosis**: You can confirm the token itself works by testing against
JSON:API:

```bash
# Get a token
TOKEN=$(curl -s -X POST https://<ID>.cms.acquia.site/oauth/token \
  -d "grant_type=client_credentials&client_id=default_client&client_secret=secret" \
  | python3 -c "import sys,json;print(json.loads(sys.stdin.read())['access_token'])")

# This works — JSON:API accepts the token
curl -s -H "Authorization: Bearer $TOKEN" \
  https://<ID>.cms.acquia.site/api | head

# This fails — Canvas API rejects it
curl -s -H "Authorization: Bearer $TOKEN" \
  https://<ID>.cms.acquia.site/canvas/api/v0/config/js_component
```

**Fix — check all three requirements on the API client:**

1. **Grant type**: "Client Credentials" must be enabled
2. **Scopes**: All three must be present: `canvas:asset_library`,
   `canvas:js_component`, `member`
3. **User in Client Credentials settings**: A Drupal user must be assigned in
   the "Client Credentials settings" section. This is at the bottom of the API
   client edit form and is easy to miss.

The third item (assigning a user) is almost always the missing piece. Without
it, the token has no user context and the Canvas API treats the request as
anonymous.

### Error: Upload succeeds but components don't appear on site

**Possible causes**:

- Components uploaded to wrong site (check `CANVAS_SITE_URL`)
- Component `status: false` in `component.yml` — change to `status: true`
- Check the Code Editor at `<CMS_URL>/canvas/code-editor/component/<name>` for errors

### Error: OAuth token request returns HTML instead of JSON

**Cause**: `CANVAS_SITE_URL` is wrong or points to the public URL instead of
the CMS URL.

**Fix**: Use the CMS URL (`https://<ID>.cms.acquia.site`), not the public URL
(`https://<name>.acquia.site`).

### Investigating a working reference site

If another Acquia Source site is already working with Canvas uploads (e.g., a
teammate's site), you can inspect its API client configuration for reference:

```
https://<their-ID>.cms.acquia.site/admin/config/services/api-clients
```

Look at the API client's grant types, scopes, and Client Credentials settings
to compare with your own configuration.

## Quick Setup Checklist

Use this checklist when setting up a new project:

- [ ] Identify the CMS URL (`<ID>.cms.acquia.site`)
- [ ] Create/configure API client with Client Credentials grant type
- [ ] Add scopes: `canvas:asset_library`, `canvas:js_component`, `member`
- [ ] Assign a User in Client Credentials settings
- [ ] Note the JSON:API prefix (`api` vs `jsonapi`)
- [ ] Create `.env` with `CANVAS_SITE_URL`, `CANVAS_CLIENT_ID`,
      `CANVAS_CLIENT_SECRET`, `CANVAS_JSONAPI_PREFIX`, `CANVAS_COMPONENT_DIR`
- [ ] Update `siteUrl` in `vite.config.js`
- [ ] Run `npm run canvas:validate` to verify component detection
- [ ] Run `npm run canvas:upload` to push components
- [ ] Verify components in Canvas Code Editor (`<CMS_URL>/canvas/code-editor/component/<name>`)
