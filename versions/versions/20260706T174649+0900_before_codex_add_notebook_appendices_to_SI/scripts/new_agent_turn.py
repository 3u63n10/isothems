#!/usr/bin/env python3
import argparse
from datetime import datetime
from zoneinfo import ZoneInfo
from pathlib import Path

parser = argparse.ArgumentParser(description="Create a timestamped agent turn log.")
parser.add_argument("--agent", required=True, help="codex, gemini, human, etc.")
parser.add_argument("--role", required=True, help="agent role")
parser.add_argument("--message", required=True, help="short task/message")
args = parser.parse_args()

ts = datetime.now(ZoneInfo("Asia/Tokyo")).strftime("%Y%m%dT%H%M%S%z")
out = Path("agent_exchange") / "tasks" / f"{ts}_{args.agent}_{args.role}.md"
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(f"""# Agent Turn — {ts}

## Agent
{args.agent}

## Role
{args.role}

## Message
{args.message}

## Required behavior
- Read memory/research_context.md first.
- Ask questions before starting if context is insufficient.
- Do not invent data or citations.
- Timestamp all outputs.
""", encoding="utf-8")
print(out)
