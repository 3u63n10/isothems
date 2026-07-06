#!/usr/bin/env bash
set -euo pipefail
PROJECT=${1:-paper}
LOOP=${2:-loop}
TS=$(python scripts/timestamp.py)
DIR="agent_exchange/loops/${TS}_${PROJECT}_${LOOP}"
mkdir -p "$DIR/outputs" "$DIR/snapshot"

cat > "$DIR/00_task.md" <<EOF
# Loop task — ${TS}

Project: ${PROJECT}
Loop: ${LOOP}

## Human task description
[WRITE TASK HERE]

## Case-specific context rule
Everything below is defined case by case. If anything needed for this task is undefined, the agent must ask before starting.

## Must read before starting
- memory/case_definition.md
- memory/research_context.md
- memory/answered_questions.md
- memory/target_journal.md
- memory/forbidden_claims.md
- memory/claims_table.md
- memory/data_inventory.md
- memory/context_bundle.md

## Direct edit/version rule
- Codex may edit directly but must snapshot before and after.
- Gemini may edit the Codex version if explicitly requested but must snapshot before and after.
- No simultaneous edits.

## Token budget rule
Use inventories and summaries first. Inspect raw files only when necessary.
EOF

cat > "$DIR/01_case_check_prompt.md" <<EOF
Read ${DIR}/00_task.md and all required memory files.
Before doing anything else, decide whether the task has enough case-specific context.
If not, stop and write blocking questions to agent_exchange/questions/.
EOF

cat > "$DIR/02_codex_draft_prompt.md" <<EOF
Read ${DIR}/00_task.md and the project memory files.
If context is insufficient, stop and write questions to agent_exchange/questions/.
Otherwise:
1. Snapshot before editing.
2. Perform the requested Codex draft task conservatively.
3. Snapshot after editing.
4. Timestamp your output and list files changed, claims added, evidence used, and missing evidence.
EOF

cat > "$DIR/03_gemini_review_or_edit_prompt.md" <<EOF
Read ${DIR}/00_task.md and the current Codex version.
First check whether context is sufficient; if not, ask questions and stop.
Then act as hostile reviewer or second editor, according to the human task.
If editing files:
1. Snapshot before editing.
2. Edit the Codex version.
3. Snapshot after editing.
Do not invent evidence.
Timestamp your output.
EOF

cat > "$DIR/04_codex_revision_prompt.md" <<EOF
Read Gemini's review/edit summary in ${DIR}/outputs/ or agent_exchange/gemini_attacks/.
Classify each criticism as accept/reject/needs human decision/already addressed/requires new data.
Apply only accepted text-level corrections.
Snapshot before and after editing.
Do not invent evidence.
EOF

bash scripts/stamp_snapshot.sh "loop_start_${PROJECT}_${LOOP}" >/dev/null

echo "$DIR"
