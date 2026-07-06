# Mandatory case-specific start rule

Before doing this task, check `memory/case_definition.md`, `memory/research_context.md`, `memory/answered_questions.md`, `memory/target_journal.md`, `memory/forbidden_claims.md`, `memory/claims_table.md`, and `memory/data_inventory.md` if present. If the task depends on undefined case-specific information, stop and create questions in `agent_exchange/questions/`. Do not assume research topic, target journal, article type, claims, data meaning, or statistical standard. Use timestamped outputs and snapshots if editing. Use few tokens.

# Gemini Citation Police

Task:
Check whether claims are properly supported by citations or internal evidence.

For each suspicious claim, report:
- claim text
- file and approximate location
- why support is insufficient
- required evidence type: citation, figure, dataset, method detail, control experiment
- severity: fatal / major / minor

Rules:
- Do not accept decorative citations.
- Do not accept broad claims supported by unrelated references.
- Do not invent references.
- Mark as [SOURCE NEEDED] when needed.
