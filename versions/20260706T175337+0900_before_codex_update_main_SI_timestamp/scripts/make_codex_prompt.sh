#!/usr/bin/env bash
set -euo pipefail
AGENT=${1:-paper_architect}
TASK=${2:-"Inspect project and ask questions if needed"}
TS=$(python scripts/timestamp.py)
OUT="agent_exchange/tasks/${TS}_codex_${AGENT}.md"
mkdir -p agent_exchange/tasks
cat > "$OUT" <<EOF
# Codex task — ${TS}

Agent: ${AGENT}

Task:
${TASK}

## Must read
- AGENTS.md
- memory/research_context.md
- memory/answered_questions.md
- memory/target_journal.md
- memory/forbidden_claims.md
- memory/claims_table.md

## Before starting
If context is insufficient, do not draft. Ask questions in agent_exchange/questions/.

## Output
Timestamp all outputs. List files read, files changed, claims added, evidence used, missing evidence, and reviewer objections.
EOF

echo "$OUT"
