# Codex handoff - 2026-07-07

Working branch: `review_20260706_1550`
Remote: `https://github.com/3u63n10/isothems`
Dropbox working folder: `C:\Users\eugen\Dropbox\00000_agents\Writing\Manuscript_20260706_for Agents`

## Current compiled files

- Main source: `main_20260706_1754.tex`
- Main checked PDF: `main_20260706_1754_finalcheck.pdf`
- SI source: `SI_20260706_2228.tex`
- SI compiled PDF: `SI_20260706_2228.pdf`
- Active SI mirror: `SI.tex`

## Latest SI correction

The previous notebook-export section was corrected because it exposed raw LaTeX/build fragments instead of reader-facing notebook blocks. The SI now uses cleaned notebook-style blocks:

- Notebook input cell: fitting and descriptor extraction
- Notebook output cell: reported descriptor table
- Notebook input cell: export a fit overlay
- Notebook output artifact
- Notebook input cell: export a model-selection table
- Notebook input cell: bootstrap summary
- Notebook input cell: descriptor matrix for classification

The section explicitly warns not to include raw `nbconvert` pages, package-install logs, LaTeX preambles, or build commands in the reader-facing SI.

## Verification

- `SI_20260706_2228.tex` compiled with `pdflatex` in three passes.
- Final PDF: `SI_20260706_2228.pdf`, 72 pages.
- Log check found no fatal LaTeX errors, no undefined references, and no rerun request.
- Remaining warnings are layout warnings only: overfull/underfull boxes and one large float.

## GitHub commits in this review branch

- `d680c85` - Apply Gemini corrections for sigma_H and update notebooks.
- `c9ca93a` - Add notebook LaTeX export guidance to SI.
- `807d95f` - Replace raw LaTeX notebook guidance with notebook blocks.

## Notes for next agent

Continue on `review_20260706_1550` until the human gives final approval to merge into `main`. The manuscript production branch should not be merged blindly because this branch contains review snapshots, timestamped files, notebooks, and generated support artifacts.
