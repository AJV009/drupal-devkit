#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="${CLAUDE_PROJECT_DIR:-.}/docs/migration/state.jsonl"
[ -f "$STATE_FILE" ] || exit 0

TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EVENT_COUNT=$(wc -l < "$STATE_FILE")

echo "{\"ts\":\"$TS\",\"phase\":null,\"agent\":\"system\",\"action\":\"session_resumed\",\"detail\":{\"reason\":\"post_compaction\",\"event_count\":$EVENT_COUNT},\"level\":\"system\"}" >> "$STATE_FILE"
echo "MIGRATION ACTIVE: Read docs/migration/state-summary.md before proceeding. If stale or missing, spawn the state-summarizer agent to generate a fresh summary from docs/migration/state.jsonl."
