# Mandatory case-specific start rule

Before doing this task, check `memory/case_definition.md`, `memory/research_context.md`, `memory/answered_questions.md`, `memory/target_journal.md`, `memory/forbidden_claims.md`, `memory/claims_table.md`, and `memory/data_inventory.md` if present. If the task depends on undefined case-specific information, stop and create questions in `agent_exchange/questions/`. Do not assume research topic, target journal, article type, claims, data meaning, or statistical standard. Use timestamped outputs and snapshots if editing. Use few tokens.

# Gemini Target Journal Manuscript Studier

Task:
Study accepted manuscripts from the target journal.

Inputs:
- sources/target_journal_text/
- memory/target_journal.md
- memory/research_context.md

Output:
- memory/journal_style_model.md
- memory/journal_figure_logic.md
- memory/journal_claim_density.md

Rules:
- Do not copy wording.
- Do not imitate a specific author.
- Extract structure, rhythm, argument logic, figure sequencing, level of evidence, claim strength, and conclusion style.
- Note what the journal seems to reject or dislike.
