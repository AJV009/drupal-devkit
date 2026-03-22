#!/usr/bin/env bash
# setup.sh — Bootstrap an Acquia Source + Canvas project for site migration
# Invoked by the setup-migration skill

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"

echo "=== Migration Project Setup (Acquia Source) ==="
echo "Plugin root: $PLUGIN_ROOT"
echo "Project root: $PROJECT_ROOT"
echo ""

# 1. Create migration directory structure
echo "1. Creating docs/migration/ directory structure..."
mkdir -p "$PROJECT_ROOT/docs/migration"/{content,screenshots/pages,issues}
touch "$PROJECT_ROOT/docs/migration/progress.md"
touch "$PROJECT_ROOT/docs/migration/decisions.md"
echo "   ✓ Directory structure created"

# 2. Set up canvas-starter reference
echo "2. Setting up canvas-starter reference..."
mkdir -p "$PROJECT_ROOT/.claude/reference"
if [ -L "$PROJECT_ROOT/.claude/reference/canvas-starter" ]; then
  echo "   ✓ canvas-starter symlink already exists"
elif [ -d "$PROJECT_ROOT/.claude/reference/canvas-starter" ]; then
  echo "   ✓ canvas-starter directory already exists"
else
  ln -sfn "$PLUGIN_ROOT/reference/canvas-starter" "$PROJECT_ROOT/.claude/reference/canvas-starter"
  echo "   ✓ canvas-starter symlink created → plugin reference"
fi

# 3. Copy project templates (if not already present)
echo "3. Copying project templates..."
if [ ! -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  cp "$PLUGIN_ROOT/templates/CLAUDE.md" "$PROJECT_ROOT/CLAUDE.md"
  echo "   ✓ CLAUDE.md copied"
else
  echo "   · CLAUDE.md already exists, skipping"
fi

if [ ! -f "$PROJECT_ROOT/.mcp.json" ]; then
  cp "$PLUGIN_ROOT/templates/.mcp.json" "$PROJECT_ROOT/.mcp.json"
  echo "   ✓ .mcp.json copied"
else
  echo "   · .mcp.json already exists, skipping"
fi

if [ -f "$PLUGIN_ROOT/templates/.env.example" ] && [ ! -f "$PROJECT_ROOT/.env.example" ]; then
  cp "$PLUGIN_ROOT/templates/.env.example" "$PROJECT_ROOT/.env.example"
  echo "   ✓ .env.example copied"
fi

# 4. Install content management dependencies
echo "4. Checking content management dependencies..."
# Acquia Source variant: components at project root (no canvas/ subdirectory)
MISSING_DEPS=""
[ -d "$PROJECT_ROOT/node_modules/dotenv" ] || MISSING_DEPS="$MISSING_DEPS dotenv"
[ -d "$PROJECT_ROOT/node_modules/drupal-jsonapi-params" ] || MISSING_DEPS="$MISSING_DEPS drupal-jsonapi-params"
[ -d "$PROJECT_ROOT/node_modules/js-yaml" ] || MISSING_DEPS="$MISSING_DEPS js-yaml"

if [ -n "$MISSING_DEPS" ]; then
  echo "   Installing:$MISSING_DEPS"
  cd "$PROJECT_ROOT" && npm install --save $MISSING_DEPS 2>/dev/null
  echo "   ✓ Dependencies installed"
else
  echo "   ✓ All content management dependencies present"
fi

# 5. Validate environment
echo "5. Validating environment..."
command -v node >/dev/null 2>&1 && echo "   ✓ node $(node -v)" || echo "   ✗ node (required)"
command -v npm >/dev/null 2>&1 && echo "   ✓ npm $(npm -v)" || echo "   ✗ npm (required)"

if [ -d "$PROJECT_ROOT/node_modules/@drupal-canvas/cli" ]; then
  echo "   ✓ canvas CLI"
else
  echo "   ⚠ canvas CLI not found in node_modules/"
fi

if [ -d "$PROJECT_ROOT/.storybook" ]; then
  echo "   ✓ storybook config"
else
  echo "   ⚠ .storybook/ not found"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Copy .env.example to .env and configure Acquia Source OAuth credentials"
echo "  2. Verify .mcp.json has correct URLs for your Acquia Source site"
echo "  3. Start migration: /migrate-drupal-canvas-source:migrate-site <source-url>"
