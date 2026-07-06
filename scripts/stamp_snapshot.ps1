param(
    [string]$Label = "snapshot"
)
$ErrorActionPreference = "Stop"
$TS = python scripts/timestamp.py
$DEST = "versions/${TS}_${Label}"
New-Item -ItemType Directory -Force -Path $DEST | Out-Null

$lightDirs = @("memory", "manuscript", "scripts", "prompts", ".codex", ".gemini", "docs")
foreach ($d in $lightDirs) {
    if (Test-Path $d) {
        Copy-Item $d -Destination $DEST -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if ($env:SNAPSHOT_RAW -eq "1") {
    foreach ($d in @("figures", "data", "protocols", "notebooks", "sources")) {
        if (Test-Path $d) { Copy-Item $d -Destination $DEST -Recurse -Force -ErrorAction SilentlyContinue }
    }
} else {
    $manifest = @()
    $manifest += "# Raw file manifest for $TS"
    $manifest += ""
    $manifest += "Raw data, figures, notebooks, protocols, and PDFs were not copied by default."
    $manifest += "Set SNAPSHOT_RAW=1 to copy them."
    foreach ($d in @("figures", "data", "protocols", "notebooks", "sources")) {
        if (Test-Path $d) {
            $manifest += ""
            $manifest += "## $d"
            Get-ChildItem $d -Recurse -File -ErrorAction SilentlyContinue | Where-Object {$_.Name -ne ".gitkeep"} | Sort-Object FullName | ForEach-Object {
                $manifest += "$($_.FullName)`t$($_.Length) bytes"
            }
        }
    }
    $manifest | Out-File -FilePath "$DEST/raw_file_manifest.md" -Encoding utf8
}

git status --short 2>$null | Out-File -FilePath "$DEST/git_status.txt" -Encoding utf8
git diff 2>$null | Out-File -FilePath "$DEST/git_diff.patch" -Encoding utf8
Write-Output $DEST
