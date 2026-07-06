#!/usr/bin/env bash
set -euo pipefail
mkdir -p \
  agent_exchange/{arbiter_decisions,codex_outputs,gemini_attacks,loops,questions,tasks} \
  data/{raw,processed} \
  figures/{draft,final} \
  manuscript memory notebooks protocols prompts/gemini prompts/shared scripts \
  sources/{bibliography_pdfs,bibliography_text,target_journal_manuscripts,target_journal_text} \
  versions

touch sources/references.bib
[ -f memory/case_definition.md ] || cp docs/TEMPLATE_case_definition.md memory/case_definition.md 2>/dev/null || true
python scripts/scan_data.py data > memory/data_inventory.md || true
python scripts/context_bundle.py > memory/context_bundle.md || true
echo "Project folders ready. Fill memory/case_definition.md and memory/research_context.md before agents start."
