#!/usr/bin/env python3
"""Extract text from PDFs into .txt files.

Usage:
  python scripts/extract_pdf_text.py sources/bibliography_pdfs sources/bibliography_text
  python scripts/extract_pdf_text.py sources/target_journal_manuscripts sources/target_journal_text

Priority:
1. pypdf if installed
2. PyMuPDF/fitz if installed
3. pdftotext command if available

This script does not OCR scanned PDFs.
"""
import argparse
import subprocess
from pathlib import Path
import sys


def extract_with_pypdf(pdf: Path) -> str:
    from pypdf import PdfReader
    reader = PdfReader(str(pdf))
    parts = []
    for i, page in enumerate(reader.pages, 1):
        text = page.extract_text() or ""
        parts.append(f"\n\n--- PAGE {i} ---\n{text}")
    return "".join(parts)


def extract_with_fitz(pdf: Path) -> str:
    import fitz
    doc = fitz.open(str(pdf))
    parts = []
    for i, page in enumerate(doc, 1):
        parts.append(f"\n\n--- PAGE {i} ---\n{page.get_text()}")
    return "".join(parts)


def extract_with_pdftotext(pdf: Path) -> str:
    result = subprocess.run(["pdftotext", "-layout", str(pdf), "-"], capture_output=True, text=True, check=True)
    return result.stdout


def extract(pdf: Path) -> str:
    errors = []
    for name, func in [("pypdf", extract_with_pypdf), ("fitz", extract_with_fitz), ("pdftotext", extract_with_pdftotext)]:
        try:
            return func(pdf)
        except Exception as e:
            errors.append(f"{name}: {e}")
    return "[TEXT EXTRACTION FAILED]\n" + "\n".join(errors)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input_dir")
    ap.add_argument("output_dir")
    args = ap.parse_args()
    inp = Path(args.input_dir)
    out = Path(args.output_dir)
    out.mkdir(parents=True, exist_ok=True)
    pdfs = sorted(inp.glob("*.pdf"))
    if not pdfs:
        print(f"No PDFs found in {inp}", file=sys.stderr)
    for pdf in pdfs:
        text = extract(pdf)
        dest = out / (pdf.stem + ".txt")
        dest.write_text(f"# SOURCE PDF: {pdf.name}\n\n{text}", encoding="utf-8", errors="replace")
        print(dest)

if __name__ == "__main__":
    main()
