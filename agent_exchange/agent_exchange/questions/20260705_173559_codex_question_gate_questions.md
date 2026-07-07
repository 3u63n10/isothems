# Codex Question Gate Questions

Timestamp: 20260705_173559

Requested task: use `C:\Users\eugen\Dropbox\00000_agents\Writing\paper_agent_pack_02` agents to work on `main.tex`.

## Blocking Questions

1. What specific task should be performed on `main.tex` now: abstract replacement, English/editorial cleanup, claims audit, journal formatting, figure/table polishing, LaTeX compilation cleanup, or another task?
2. What is the target journal and manuscript type? `main.tex` currently uses `\documentclass[journal=jacsat,manuscript=article]{achemso}`, but the agent pack case files list the target journal and article type as undefined.
3. What claims are allowed for this manuscript? The pack's `memory/claims_table.md` is undefined.
4. What claims are forbidden for this specific manuscript beyond the global defaults in `memory/forbidden_claims.md`?
5. Which evidence sources should be treated as authoritative for `main.tex`: the existing `references.bib`, local PDFs, `SI.tex`, notebooks, figures, or other files?
6. May Codex make direct text edits to `main.tex` after creating snapshots, or should it only produce a marked-up review first?
7. Should the abstract be rewritten now? It is still the default `achemso` demonstration abstract and is not manuscript-specific.

## Useful but Non-Blocking Questions

1. Should the manuscript remain in ACS `achemso` format or be generalized for a different journal?
2. Should the writing style be conservative review/guideline style, perspective style, or article style?
3. Should Spanish comments and mixed-language notes in the LaTeX preamble be cleaned, left as author notes, or moved to a separate development log?
4. Are bibliography edits in scope, or should citations and `.bib` files remain untouched?
5. Should line numbering and double spacing remain enabled for review submission?

## Dangerous Assumptions Not Made

1. I did not assume that JACS is the real target journal from the current `achemso` option.
2. I did not assume that the paper is a review, guideline article, perspective, or full research article.
3. I did not assume that claims about SDG 6, PFAS, machine learning, model selection, or thermodynamic comparability are all approved.
4. I did not assume that local PDFs or bibliography entries are sufficient evidence for every citation-backed statement.
5. I did not assume that direct manuscript rewriting is allowed before the case definition is filled.

## Files Checked Before Stopping

1. `C:\Users\eugen\Dropbox\00000_agents\Writing\paper_agent_pack_02\AGENTS.md`
2. `C:\Users\eugen\Dropbox\00000_agents\Writing\paper_agent_pack_02\README.md`
3. `C:\Users\eugen\Dropbox\00000_agents\Writing\paper_agent_pack_02\.codex\agents\question_gate.toml`
4. `C:\Users\eugen\Dropbox\00000_agents\Writing\paper_agent_pack_02\memory\case_definition.md`
5. `C:\Users\eugen\Dropbox\00000_agents\Writing\paper_agent_pack_02\memory\research_context.md`
6. `C:\Users\eugen\Dropbox\00000_agents\Writing\paper_agent_pack_02\memory\answered_questions.md`
7. `C:\Users\eugen\Dropbox\00000_agents\Writing\paper_agent_pack_02\memory\target_journal.md`
8. `C:\Users\eugen\Dropbox\00000_agents\Writing\paper_agent_pack_02\memory\forbidden_claims.md`
9. `C:\Users\eugen\Dropbox\00000_agents\Writing\paper_agent_pack_02\memory\claims_table.md`
10. `C:\Users\eugen\Dropbox\00000_agents\Writing\paper_agent_pack_02\memory\data_inventory.md`
11. `main.tex`
12. `STATUS_2026-03-26.md`

## Next Allowed Step

After the blocking questions are answered, Codex can create a before-snapshot and start the selected `main.tex` task using the relevant agent role, most likely `revision_worker`, `latex_checker`, or `paper_architect`.
