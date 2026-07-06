#!/usr/bin/env bash
set -euo pipefail
LABEL=${1:-snapshot}
TS=$(python scripts/timestamp.py)
DEST="versions/${TS}_${LABEL}"
mkdir -p "$DEST"

# Default snapshots are light: manuscript, memory, scripts, prompts, configs, and git diff.
# Raw data/PDFs can be huge and are not supposed to change. Set SNAPSHOT_RAW=1 to copy them too.
LIGHT_DIRS=(memory manuscript scripts prompts .codex .gemini docs)
for d in "${LIGHT_DIRS[@]}"; do
  if [ -e "$d" ]; then
    mkdir -p "$DEST/$(dirname "$d")"
    cp -R "$d" "$DEST/" 2>/dev/null || true
  fi
done

if [ "${SNAPSHOT_RAW:-0}" = "1" ]; then
  for d in figures data protocols notebooks sources; do
    if [ -e "$d" ]; then
      mkdir -p "$DEST/$(dirname "$d")"
      cp -R "$d" "$DEST/" 2>/dev/null || true
    fi
  done
else
  {
    echo "# Raw file manifest for $TS"
    echo
    echo "Raw data, figures, notebooks, protocols, and PDFs were not copied by default."
    echo "Set SNAPSHOT_RAW=1 to copy them."
    echo
    for d in figures data protocols notebooks sources; do
      if [ -e "$d" ]; then
        echo "## $d"
        find "$d" -type f ! -name '.gitkeep' -printf '%p\t%s bytes\n' 2>/dev/null | sort || true
        echo
      fi
    done
  } > "$DEST/raw_file_manifest.md"
fi

git status --short > "$DEST/git_status.txt" 2>/dev/null || true
git diff > "$DEST/git_diff.patch" 2>/dev/null || true

echo "$DEST"
