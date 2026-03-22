#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="${CLAUDE_PROJECT_DIR:-.}/docs/migration/state.jsonl"
[ -f "$STATE_FILE" ] || exit 0

TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EVENT_COUNT=$(wc -l < "$STATE_FILE")

echo "{\"ts\":\"$TS\",\"phase\":null,\"agent\":\"system\",\"action\":\"compaction_imminent\",\"detail\":{\"trigger\":\"auto_or_manual\",\"event_count\":$EVENT_COUNT},\"level\":\"system\"}" >> "$STATE_FILE"
