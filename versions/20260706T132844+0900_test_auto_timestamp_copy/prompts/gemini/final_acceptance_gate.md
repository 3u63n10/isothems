# Mandatory case-specific start rule

Before doing this task, check `memory/case_definition.md`, `memory/research_context.md`, `memory/answered_questions.md`, `memory/target_journal.md`, `memory/forbidden_claims.md`, `memory/claims_table.md`, and `memory/data_inventory.md` if present. If the task depends on undefined case-specific information, stop and create questions in `agent_exchange/questions/`. Do not assume research topic, target journal, article type, claims, data meaning, or statistical standard. Use timestamped outputs and snapshots if editing. Use few tokens.

# Final Acceptance Gate

Task:
Decide whether the current manuscript is ready for human final editing or still needs another loop.

Check:
- All [EVIDENCE NEEDED] markers
- All [SOURCE NEEDED] markers
- All [PARAMETER NEEDED] markers
- All [STATISTICS NEEDED] markers
- Citation consistency
- Figure references
- Target journal fit
- AI disclosure language

Output:
- Ready / Not ready
- Blocking items
- Non-blocking items
- Recommended next loop
