#!/usr/bin/env bash
set -euo pipefail
PROMPT=${1:-prompts/gemini/journal_reviewer.md}
OUTPUT_DIR=${2:-agent_exchange/gemini_attacks}
TS=$(python scripts/timestamp.py)
mkdir -p "$OUTPUT_DIR"
OUT="$OUTPUT_DIR/${TS}_gemini_$(basename "$PROMPT" .md).md"

if ! command -v gemini >/dev/null 2>&1; then
  echo "gemini CLI not found. Install/authenticate Gemini CLI first." >&2
  exit 1
fi

TMP=$(mktemp)
{
  echo "# Project context"
  cat memory/research_context.md memory/answered_questions.md memory/target_journal.md memory/forbidden_claims.md memory/claims_table.md 2>/dev/null || true
  echo "\n# Prompt"
  cat "$PROMPT"
  echo "\n# Manuscript"
  cat manuscript/*.tex 2>/dev/null || true
  echo "\n# Memory summaries"
  cat memory/project_summary.md memory/literature_map.md memory/data_interpretation.md memory/journal_style_model.md 2>/dev/null || true
} > "$TMP"

gemini -p "$(cat "$TMP")" > "$OUT"
rm -f "$TMP"
echo "$OUT"
