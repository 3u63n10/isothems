param(
    [string]$Project = "paper",
    [string]$Loop = "loop"
)
$ErrorActionPreference = "Stop"
$TS = python scripts/timestamp.py
$DIR = "agent_exchange/loops/${TS}_${Project}_${Loop}"
New-Item -ItemType Directory -Force -Path "$DIR/outputs" | Out-Null
New-Item -ItemType Directory -Force -Path "$DIR/snapshot" | Out-Null

@"
# Loop task — $TS

Project: $Project
Loop: $Loop

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
"@ | Out-File -FilePath "$DIR/00_task.md" -Encoding utf8

@"
Read $DIR/00_task.md and all required memory files.
Before doing anything else, decide whether the task has enough case-specific context.
If not, stop and write blocking questions to agent_exchange/questions/.
"@ | Out-File -FilePath "$DIR/01_case_check_prompt.md" -Encoding utf8

@"
Read $DIR/00_task.md and the project memory files.
If context is insufficient, stop and write questions to agent_exchange/questions/.
Otherwise snapshot before editing, draft conservatively, snapshot after editing, and report changed files, claims, evidence, and missing evidence.
"@ | Out-File -FilePath "$DIR/02_codex_draft_prompt.md" -Encoding utf8

@"
Read $DIR/00_task.md and the current Codex version.
First check whether context is sufficient; if not, ask questions and stop.
Then act as hostile reviewer or second editor, according to the human task.
If editing files, snapshot before and after editing. Do not invent evidence.
"@ | Out-File -FilePath "$DIR/03_gemini_review_or_edit_prompt.md" -Encoding utf8

@"
Read Gemini's review/edit summary in $DIR/outputs/ or agent_exchange/gemini_attacks/.
Classify each criticism as accept/reject/needs human decision/already addressed/requires new data.
Apply only accepted text-level corrections. Snapshot before and after editing. Do not invent evidence.
"@ | Out-File -FilePath "$DIR/04_codex_revision_prompt.md" -Encoding utf8

./scripts/stamp_snapshot.ps1 "loop_start_${Project}_${Loop}" | Out-Null
Write-Output $DIR
