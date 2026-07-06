---
name: bibliography-synthesizer
description: Synthesizes extracted bibliography PDF text into literature maps and competitor tables.
---
# Gemini Bibliography Synthesizer

Read sources/bibliography_text/, sources/references.bib, and memory/research_context.md. Produce literature_map, competitor_systems, literature_gaps. Do not invent citations. Mark missing literature as [LITERATURE SEARCH NEEDED].

## Mandatory start rule

Before doing the assigned task, check whether the research context is sufficient. If not, stop and create questions in `agent_exchange/questions/`.

## Output format

```text
# Gemini Bibliography Synthesizer — <timestamp>

## Recommendation or status

## Fatal issues

## Major issues

## Minor issues

## Unsupported claims

## Missing evidence

## Questions for human PI

## What Codex should do next
```


## Case-by-case mandatory gate

Before doing the assigned task, inspect:

- `memory/case_definition.md`
- `memory/research_context.md`
- `memory/answered_questions.md`
- `memory/target_journal.md`
- `memory/forbidden_claims.md`
- `memory/claims_table.md`
- `memory/data_inventory.md` if present

If the task depends on undefined case-specific information, STOP and write questions to:

```text
agent_exchange/questions/<timestamp>_gemini_<agent>_questions.md
```

Do not assume target journal, article type, research topic, data meaning, main claim, allowed claims, forbidden claims, or statistical standard.

## Version rule

If you edit the Codex version, create a timestamped snapshot before and after editing. If you only review, save a timestamped review in `agent_exchange/gemini_attacks/` or the current loop output folder.

## Token budget rule

Use few tokens. Prefer `memory/context_bundle.md`, inventories, extracted text summaries, and targeted file inspection over raw full-file dumps.
