#!/usr/bin/env python3
"""Create a token-efficient context bundle for agents.

Usage:
  python scripts/context_bundle.py > memory/context_bundle.md

The bundle points agents to relevant files without pasting entire PDFs/manuscripts/data.
"""
from pathlib import Path
from datetime import datetime
try:
    from zoneinfo import ZoneInfo
    TS = datetime.now(ZoneInfo("Asia/Tokyo")).strftime("%Y%m%dT%H%M%S%z")
except Exception:
    TS = datetime.now().strftime("%Y%m%dT%H%M%S")

ROOT = Path('.')

def first_lines(path, n=40, chars=4000):
    try:
        text = path.read_text(encoding='utf-8', errors='replace')
        lines = text.splitlines()[:n]
        out = '\n'.join(lines)
        if len(out) > chars:
            out = out[:chars] + '\n[TRUNCATED]'
        return out
    except Exception as e:
        return f"[READ FAILED: {e}]"

def list_files(folder, exts=None, limit=80):
    p = Path(folder)
    if not p.exists():
        return [f"[MISSING] {folder}"]
    files = []
    for f in sorted(p.rglob('*')):
        if f.is_file() and f.name != '.gitkeep':
            if exts is None or f.suffix.lower() in exts:
                files.append(f)
    out=[]
    for f in files[:limit]:
        out.append(f"- {f} ({f.stat().st_size} bytes)")
    if len(files) > limit:
        out.append(f"- [TRUNCATED: {len(files)-limit} more files]")
    if not out:
        out.append("[NO FILES FOUND]")
    return out

print(f"# Context Bundle — {TS}\n")
print("This is a token-efficient index. It is not a substitute for reading required evidence.\n")

for mf in [
    'memory/case_definition.md',
    'memory/research_context.md',
    'memory/answered_questions.md',
    'memory/target_journal.md',
    'memory/forbidden_claims.md',
    'memory/claims_table.md',
    'memory/data_inventory.md',
    'memory/project_summary.md',
    'memory/data_interpretation.md',
    'memory/journal_style_model.md',
    'memory/literature_map.md',
]:
    p=Path(mf)
    print(f"\n## {mf}\n")
    if p.exists():
        print(first_lines(p, n=80, chars=6000))
    else:
        print("[MISSING]")

print("\n## Data files\n")
print('\n'.join(list_files('data', limit=120)))
print("\n## Figures\n")
print('\n'.join(list_files('figures', limit=120)))
print("\n## Bibliography PDFs\n")
print('\n'.join(list_files('sources/bibliography_pdfs', {'.pdf'}, limit=120)))
print("\n## Extracted bibliography text\n")
print('\n'.join(list_files('sources/bibliography_text', {'.txt'}, limit=120)))
print("\n## Target-journal manuscripts\n")
print('\n'.join(list_files('sources/target_journal_manuscripts', {'.pdf'}, limit=120)))
print("\n## Extracted target-journal text\n")
print('\n'.join(list_files('sources/target_journal_text', {'.txt'}, limit=120)))
print("\n## Manuscript files\n")
print('\n'.join(list_files('manuscript', {'.tex', '.md'}, limit=120)))
