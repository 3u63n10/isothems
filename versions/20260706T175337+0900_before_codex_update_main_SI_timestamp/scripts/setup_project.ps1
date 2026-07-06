$ErrorActionPreference = "Stop"
$dirs = @(
"agent_exchange/arbiter_decisions", "agent_exchange/codex_outputs", "agent_exchange/gemini_attacks", "agent_exchange/loops", "agent_exchange/questions", "agent_exchange/tasks",
"data/raw", "data/processed", "figures/draft", "figures/final", "manuscript", "memory", "notebooks", "protocols", "prompts/gemini", "prompts/shared", "scripts",
"sources/bibliography_pdfs", "sources/bibliography_text", "sources/target_journal_manuscripts", "sources/target_journal_text", "versions"
)
foreach ($d in $dirs) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
if (!(Test-Path "sources/references.bib")) { New-Item -ItemType File -Path "sources/references.bib" | Out-Null }
python scripts/scan_data.py data | Out-File -FilePath memory/data_inventory.md -Encoding utf8
python scripts/context_bundle.py | Out-File -FilePath memory/context_bundle.md -Encoding utf8
Write-Output "Project folders ready. Fill memory/case_definition.md and memory/research_context.md before agents start."
