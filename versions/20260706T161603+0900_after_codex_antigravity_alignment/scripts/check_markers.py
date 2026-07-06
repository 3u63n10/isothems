#!/usr/bin/env python3
"""Find unresolved evidence/source/statistics/parameter markers."""
from pathlib import Path
markers = ["[EVIDENCE NEEDED]", "[SOURCE NEEDED]", "[PARAMETER NEEDED]", "[STATISTICS NEEDED]", "[DATA NEEDED]", "[QUESTION]", "[FIGURE CLARIFICATION NEEDED]"]
for path in list(Path('manuscript').glob('*.tex')) + list(Path('memory').glob('*.md')):
    text = path.read_text(encoding='utf-8', errors='replace')
    for i, line in enumerate(text.splitlines(), 1):
        for m in markers:
            if m in line:
                print(f"{path}:{i}: {m}: {line.strip()[:240]}")
