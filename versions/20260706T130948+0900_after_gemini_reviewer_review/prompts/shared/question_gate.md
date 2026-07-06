# Mandatory case-specific start rule

Before doing this task, check `memory/case_definition.md`, `memory/research_context.md`, `memory/answered_questions.md`, `memory/target_journal.md`, `memory/forbidden_claims.md`, `memory/claims_table.md`, and `memory/data_inventory.md` if present. If the task depends on undefined case-specific information, stop and create questions in `agent_exchange/questions/`. Do not assume research topic, target journal, article type, claims, data meaning, or statistical standard. Use timestamped outputs and snapshots if editing. Use few tokens.

# Question Gate Prompt

You must not draft, revise, analyze data, or summarize literature until the project context is sufficient.

Read these files:

```text
memory/research_context.md
memory/answered_questions.md
memory/target_journal.md
memory/forbidden_claims.md
memory/claims_table.md
```

If anything important is missing, create a timestamped question file in:

```text
agent_exchange/questions/
```

Ask only useful questions. Use this format:

```text
# Questions before starting — <timestamp>

## Blocking questions
1.
2.
3.

## Useful but non-blocking questions
1.
2.

## Dangerous assumptions I refuse to make
1.
2.

## Files that must be filled before next loop
-
```

Minimum required context:

- exact research topic
- target journal or candidate journals
- central hypothesis
- what data exist
- what data do not exist
- figure list or expected figure logic
- bibliography folder location
- sample target-journal manuscripts folder location
- forbidden claims
- whether the paper is full article, communication, technical note, or review
- preferred tone and journal style
