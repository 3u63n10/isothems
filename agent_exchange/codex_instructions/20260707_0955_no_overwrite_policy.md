# Codex instruction - no overwrite policy

Timestamp: 2026-07-07 09:55 JST

## Rule

Never overwrite manuscript deliverables, compiled PDFs, handoff notes, notebook snapshots, or agent-facing instruction files unless the user explicitly asks for an overwrite.

## Required workflow

When producing a corrected or compiled artifact:

1. Create a new file with a timestamp in the filename.
2. Use the format `YYYYMMDD_HHMM`.
3. Keep the previous file intact, even if it is obsolete or visually wrong.
4. Put the new artifact in the active Dropbox project folder.
5. If the change is agent-facing, also put a timestamped note under `agent_exchange/`.
6. Report the exact path of the new file to the user.

## Example

Instead of overwriting:

`SI_20260706_2228.pdf`

create:

`SI_20260707_0955.pdf`

## Rationale

This manuscript workflow uses multiple reviewing agents and human visual checks.
Timestamped files preserve provenance, prevent accidental loss of reviewed
versions, and make it possible to compare agent outputs without reconstructing
state from Git history alone.
