import os
import shutil
import sys
import subprocess
from datetime import datetime

def stamp_snapshot(label="snapshot"):
    try:
        from zoneinfo import ZoneInfo
        tz = ZoneInfo("Asia/Tokyo")
    except Exception:
        tz = None
    
    ts = datetime.now(tz).strftime("%Y%m%dT%H%M%S%z")
    dest = f"versions/{ts}_{label}"
    os.makedirs(dest, exist_ok=True)
    
    # Automatically create YYYYMMDD_HHMM timestamped copy of main.tex and SI.tex in the root folder
    ts_short = datetime.now(tz).strftime("%Y%m%d_%H%M")
    if os.path.exists("main.tex"):
        try:
            shutil.copy("main.tex", f"main_{ts_short}.tex")
        except Exception:
            pass
    if os.path.exists("SI.tex"):
        try:
            shutil.copy("SI.tex", f"SI_{ts_short}.tex")
        except Exception:
            pass
    
    light_dirs = ["memory", "manuscript", "scripts", "prompts", ".codex", ".gemini", "docs"]
    for d in light_dirs:
        if os.path.exists(d):
            # Avoid copying the versions directory itself if it's nested (not in list)
            # copytree but ignore errors/silently continue
            try:
                # To copy recursively, if dest exists, shutil.copytree fails in older python,
                # but since dest/d won't exist yet, it's fine.
                shutil.copytree(d, os.path.join(dest, d), dirs_exist_ok=True)
            except Exception as e:
                pass
                
    snapshot_raw = os.environ.get("SNAPSHOT_RAW") == "1"
    raw_dirs = ["figures", "data", "protocols", "notebooks", "sources"]
    
    if snapshot_raw:
        for d in raw_dirs:
            if os.path.exists(d):
                try:
                    shutil.copytree(d, os.path.join(dest, d), dirs_exist_ok=True)
                except Exception:
                    pass
    else:
        manifest_lines = [
            f"# Raw file manifest for {ts}",
            "",
            "Raw data, figures, notebooks, protocols, and PDFs were not copied by default.",
            "Set SNAPSHOT_RAW=1 to copy them."
        ]
        for d in raw_dirs:
            if os.path.exists(d):
                manifest_lines.append("")
                manifest_lines.append(f"## {d}")
                for root, _, files in os.walk(d):
                    for file in sorted(files):
                        if file == ".gitkeep":
                            continue
                        full_path = os.path.join(root, file)
                        try:
                            size = os.path.getsize(full_path)
                            manifest_lines.append(f"{full_path}\t{size} bytes")
                        except Exception:
                            pass
        with open(os.path.join(dest, "raw_file_manifest.md"), "w", encoding="utf-8") as f:
            f.write("\n".join(manifest_lines))
            
    # git status --short
    try:
        status_out = subprocess.check_output(["git", "status", "--short"], stderr=subprocess.DEVNULL)
        with open(os.path.join(dest, "git_status.txt"), "wb") as f:
            f.write(status_out)
    except Exception:
        pass
        
    # git diff
    try:
        diff_out = subprocess.check_output(["git", "diff"], stderr=subprocess.DEVNULL)
        with open(os.path.join(dest, "git_diff.patch"), "wb") as f:
            f.write(diff_out)
    except Exception:
        pass
        
    print(dest)

if __name__ == "__main__":
    label = sys.argv[1] if len(sys.argv) > 1 else "snapshot"
    stamp_snapshot(label)
