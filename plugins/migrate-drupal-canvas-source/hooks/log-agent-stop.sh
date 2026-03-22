#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="${CLAUDE_PROJECT_DIR:-.}/docs/migration/state.jsonl"
[ -f "$STATE_FILE" ] || exit 0

INPUT=$(cat)
AGENT=$(echo "$INPUT" | jq -r '.agent_type // "unknown"')
MESSAGE=$(echo "$INPUT" | jq -r '.last_assistant_message // ""' | head -c 500)
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Determine success or failure from message content.
# Note: simple keyword grep may false-positive on "No errors found" or
# "Previously blocked item resolved". This is acceptable — the hook is a
# safety net; working agents write their own rich action-level events.
if echo "$MESSAGE" | grep -qiE '(failed|error|blocked|could not|unable to)'; then
  ACTION="agent_failed"
else
  ACTION="agent_completed"
fi

# Escape message for JSON embedding
ESCAPED_MSG=$(echo "$MESSAGE" | jq -Rs '.')

echo "{\"ts\":\"$TS\",\"phase\":null,\"agent\":\"$AGENT\",\"action\":\"$ACTION\",\"detail\":{\"summary\":$ESCAPED_MSG},\"level\":\"agent\"}" >> "$STATE_FILE"

# Check if progress.md was updated by this agent
PROGRESS_FILE="${CLAUDE_PROJECT_DIR:-.}/docs/migration/progress.md"
SKIP_AGENTS="state-summarizer|artifact-checker|phase-verifier"
if [ -f "$PROGRESS_FILE" ] && ! echo "$AGENT" | grep -qE "^($SKIP_AGENTS)$"; then
  if [ "$(find "$PROGRESS_FILE" -mmin -10 2>/dev/null)" = "" ]; then
    echo "WARNING: Agent '$AGENT' completed without updating progress.md. Orchestrator should verify progress.md is current."
  fi
fi
