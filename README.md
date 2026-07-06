# Paper Antagonist Agents

A local, timestamped, antagonistic agent system for scientific manuscript writing.

Design:

```text
Codex builds and edits conservatively.
Gemini CLI attacks, audits, studies target-journal style, and can edit the Codex version when explicitly asked.
Human PI decides every scientific claim.
```

## Critical rule

Everything important is defined **case by case**.

Agents must ask before starting whenever the current task depends on undefined:

- research topic,
- target journal,
- article type,
- central hypothesis,
- main claim,
- allowed claims,
- forbidden claims,
- data meaning,
- statistical standard,
- figure logic,
- AI disclosure.

No agent may reuse context from another manuscript unless the human explicitly says so.

## Main folders

```text
memory/                                # case context, claims, questions, style models
manuscript/                            # LaTeX manuscript
data/raw/                              # raw measurements, never modified
data/processed/                        # processed data
figures/draft/                         # draft figures/screenshots/images
figures/final/                         # final figures
sources/bibliography_pdfs/             # literature/context PDFs
sources/bibliography_text/             # extracted bibliography text
sources/target_journal_manuscripts/    # accepted papers from target journal
sources/target_journal_text/           # extracted target-journal text
agent_exchange/                        # questions, Codex outputs, Gemini attacks, loops
versions/                              # timestamped snapshots
.codex/agents/                         # Codex custom agents
.gemini/agents/                        # Gemini CLI agents
scripts/                               # local helpers
```

## Quickstart on Linux/WSL/Mac

```bash
unzip paper_antagonist_agents.zip
cd paper_agent_pack
bash scripts/setup_project.sh
```

## Quickstart on Windows PowerShell

```powershell
Expand-Archive paper_antagonist_agents.zip -DestinationPath .
cd paper_agent_pack
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
./scripts/setup_project.ps1
```

## Before the first real loop

Fill these files for the current case:

```text
memory/case_definition.md
memory/research_context.md
memory/answered_questions.md
memory/target_journal.md
memory/forbidden_claims.md
```

It is acceptable to write `undefined`. Agents must ask when an undefined item becomes necessary.

## Add context files

```text
sources/bibliography_pdfs/              # background PDFs
sources/target_journal_manuscripts/     # accepted manuscripts from target journal
data/raw/                               # raw measurements
/data/processed/                        # processed measurements
figures/draft/ and figures/final/       # figures/images
notebooks/                              # notebooks
protocols/                              # methods/protocols
```

## Build token-efficient context

```bash
python scripts/extract_pdf_text.py sources/bibliography_pdfs sources/bibliography_text
python scripts/extract_pdf_text.py sources/target_journal_manuscripts sources/target_journal_text
python scripts/scan_data.py data > memory/data_inventory.md
python scripts/context_bundle.py > memory/context_bundle.md
```

The system is designed to save tokens by making agents read inventories and summaries first.

## Start a loop

```bash
bash scripts/start_loop.sh "project_name" "round_01"
```

or on Windows:

```powershell
./scripts/start_loop.ps1 "project_name" "round_01"
```

The command creates:

```text
agent_exchange/loops/<timestamp>_<project>_<loop>/
```

with prompts for Codex and Gemini.

## Default AI routing

Codex:

- direct manuscript editing,
- Methods/Results/Discussion drafting,
- Python summaries,
- LaTeX checks,
- accepted revisions.

Gemini:

- bibliography synthesis,
- target-journal style study,
- hostile review,
- statistical/citation/mechanism attacks,
- second editing of Codex drafts when requested.

## Versioning

Before and after major edits:

```bash
bash scripts/stamp_snapshot.sh "before_codex_results"
bash scripts/stamp_snapshot.sh "after_codex_results"
bash scripts/stamp_snapshot.sh "before_gemini_edit"
bash scripts/stamp_snapshot.sh "after_gemini_edit"
```

PowerShell:

```powershell
./scripts/stamp_snapshot.ps1 "before_codex_results"
./scripts/stamp_snapshot.ps1 "after_codex_results"
./scripts/stamp_snapshot.ps1 "before_gemini_edit"
./scripts/stamp_snapshot.ps1 "after_gemini_edit"
```

Snapshots are light by default. They copy manuscript, memory, prompts, configs, docs, scripts, and git diff. They do not duplicate raw PDFs/data unless `SNAPSHOT_RAW=1`.

## Recommended loop

```text
1. Question gate asks missing case-specific questions.
2. Human answers in memory/answered_questions.md.
3. Gemini studies bibliography and target-journal manuscripts.
4. Codex builds research context and data interpretation.
5. Codex drafts Methods/Results/Discussion.
6. Gemini attacks or edits the Codex version.
7. Codex applies accepted corrections.
8. Human makes final decisions.
```

## Safety/integrity

- Do not list AI as author.
- Do not invent data, citations, mechanisms, or statistics.
- Do not hide missing experiments.
- Do not change raw data.
- Mark uncertain claims explicitly.
- Keep a claim-to-evidence table.
