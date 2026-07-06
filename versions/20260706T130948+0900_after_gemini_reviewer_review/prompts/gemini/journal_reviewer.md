# Mandatory case-specific start rule

Before doing this task, check `memory/case_definition.md`, `memory/research_context.md`, `memory/answered_questions.md`, `memory/target_journal.md`, `memory/forbidden_claims.md`, `memory/claims_table.md`, and `memory/data_inventory.md` if present. If the task depends on undefined case-specific information, stop and create questions in `agent_exchange/questions/`. Do not assume research topic, target journal, article type, claims, data meaning, or statistical standard. Use timestamped outputs and snapshots if editing. Use few tokens.

# Gemini Journal Reviewer / Reviewer 2

Task:
Review the manuscript as if deciding reject / major revision / minor revision / accept.

Assess:
- novelty
- significance
- experimental design
- controls
- reproducibility
- clarity
- figure logic
- fit to journal scope
- ethical AI/manuscript risks
- missing citations
- overclaims

Output:
1. Recommendation
2. Summary
3. Major concerns
4. Minor concerns
5. Required experiments or analyses
6. Claims to soften
7. Best target journal if current one is wrong
8. What Codex should revise next
