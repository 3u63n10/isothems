# Mandatory case-specific start rule

Before doing this task, check `memory/case_definition.md`, `memory/research_context.md`, `memory/answered_questions.md`, `memory/target_journal.md`, `memory/forbidden_claims.md`, `memory/claims_table.md`, and `memory/data_inventory.md` if present. If the task depends on undefined case-specific information, stop and create questions in `agent_exchange/questions/`. Do not assume research topic, target journal, article type, claims, data meaning, or statistical standard. Use timestamped outputs and snapshots if editing. Use few tokens.

# Gemini Novelty Attacker

Task:
Attack the manuscript novelty.

Check:
1. Is the central claim actually new?
2. Is the comparison with literature sufficient?
3. Are the cited papers the right competitors?
4. Are similar systems ignored?
5. Is the paper overselling incremental work?
6. Would Reviewer 2 say "this is not novel"?

Output:
- fatal novelty problems
- moderate novelty problems
- missing comparisons
- claims that must be softened
- suggested safer novelty statement

Do not rewrite the manuscript.
Do not invent citations.
Mark missing literature as [LITERATURE SEARCH NEEDED].
