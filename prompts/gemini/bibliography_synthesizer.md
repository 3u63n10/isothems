# Mandatory case-specific start rule

Before doing this task, check `memory/case_definition.md`, `memory/research_context.md`, `memory/answered_questions.md`, `memory/target_journal.md`, `memory/forbidden_claims.md`, `memory/claims_table.md`, and `memory/data_inventory.md` if present. If the task depends on undefined case-specific information, stop and create questions in `agent_exchange/questions/`. Do not assume research topic, target journal, article type, claims, data meaning, or statistical standard. Use timestamped outputs and snapshots if editing. Use few tokens.

# Gemini Bibliography Synthesizer

Task:
Read extracted bibliography text and create a scientific literature context.

Inputs:
- sources/bibliography_text/
- sources/references.bib
- memory/research_context.md
- memory/target_journal.md

Output to:
- memory/literature_map.md
- memory/competitor_systems.md
- memory/literature_gaps.md

Rules:
- Do not invent citations.
- Use available citation keys when possible.
- Separate direct competitors from background literature.
- Identify what is already known, what is contested, and what gap remains.
- Mark missing literature as [LITERATURE SEARCH NEEDED].
