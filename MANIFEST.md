# Manifest

## Core instructions

- `AGENTS.md` — Codex repository-wide instructions.
- `GEMINI.md` — Gemini CLI repository-wide adversarial instructions.

## Case/memory files

- `memory/case_definition.md` — per-case manuscript definition; agents must ask if needed fields are undefined.
- `memory/research_context.md` — human research topic/context.
- `memory/answered_questions.md` — human answers to agent questions.
- `memory/target_journal.md` — journal target and constraints.
- `memory/forbidden_claims.md` — claims agents must not make.
- `memory/claims_table.md` — claim-to-evidence table.
- `memory/data_inventory.md` — generated multimodal data inventory.
- `memory/context_bundle.md` — generated token-efficient context bundle.

## Codex agents

- `.codex/agents/question_gate.toml`
- `.codex/agents/research_context_builder.toml`
- `.codex/agents/bibliography_context_builder.toml`
- `.codex/agents/journal_manuscript_studier.toml`
- `.codex/agents/data_interpreter.toml`
- `.codex/agents/paper_architect.toml`
- `.codex/agents/methods_writer.toml`
- `.codex/agents/results_writer.toml`
- `.codex/agents/discussion_writer.toml`
- `.codex/agents/revision_worker.toml`
- `.codex/agents/latex_checker.toml`

## Gemini agents

- `.gemini/agents/question-gate.md`
- `.gemini/agents/bibliography-synthesizer.md`
- `.gemini/agents/target-journal-studier.md`
- `.gemini/agents/data-interpretation-attacker.md`
- `.gemini/agents/novelty-attacker.md`
- `.gemini/agents/citation-police.md`
- `.gemini/agents/statistical-skeptic.md`
- `.gemini/agents/mechanism-attacker.md`
- `.gemini/agents/reviewer-2.md`
- `.gemini/agents/final-acceptance-gate.md`

## Scripts

- `scripts/setup_project.sh` / `scripts/setup_project.ps1`
- `scripts/start_loop.sh` / `scripts/start_loop.ps1`
- `scripts/stamp_snapshot.sh` / `scripts/stamp_snapshot.ps1`
- `scripts/extract_pdf_text.py`
- `scripts/scan_data.py`
- `scripts/context_bundle.py`
- `scripts/check_markers.py`
- `scripts/run_gemini_review.sh`
- `scripts/make_codex_prompt.sh`
- `scripts/new_agent_turn.py`
- `scripts/timestamp.py`

## Docs

- `docs/CASE_BY_CASE_POLICY.md`
- `docs/WORKFLOW.md`
- `docs/LOOP_PROTOCOL.md`
- `docs/AI_ROUTING.md`
- `docs/QUESTIONNAIRE.md`
- `docs/WINDOWS_QUICKSTART.md`
- `docs/README_FOR_HUMAN_LOG.md`
- `docs/TEMPLATE_case_definition.md`
