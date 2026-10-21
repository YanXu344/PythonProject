param(
    [string]$CommitMessage = ""
)

$ErrorActionPreference = "Stop"

$src = "C:\Users\Redmi\PycharmProjects\PythonProject\LiMu"
$repoRoot = $PSScriptRoot
$dst = Join-Path $repoRoot "Deeplearning\LiMu"

Write-Host ">>> Syncing files from $src to $dst ..." -ForegroundColor Cyan

if (!(Test-Path $dst)) {
    New-Item -ItemType Directory -Path $dst -Force | Out-Null
}

Get-ChildItem -Path $src -Recurse | Where-Object {
    $_.FullName -notmatch '\\\.ipynb_checkpoints' -and $_.FullName -notmatch '\\data(\\.*)?$'
} | ForEach-Object {
    $relPath = $_.FullName.Substring($src.Length).TrimStart('\', '/')
    $targetPath = Join-Path $dst $relPath
    if ($_.PSIsContainer) {
        if (!(Test-Path $targetPath)) {
            New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
        }
    } else {
        $parentDir = Split-Path $targetPath -Parent
        if (!(Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }
        if (!(Test-Path $targetPath) -or ((Get-Item $_.FullName).LastWriteTimeUtc -gt (Get-Item $targetPath).LastWriteTimeUtc)) {
            Copy-Item -Path $_.FullName -Destination $targetPath -Force
        }
    }
}

Set-Location $repoRoot

$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host ">>> No new changes detected. Everything is up to date!" -ForegroundColor Green
    exit 0
}

Write-Host ">>> Detected file changes:" -ForegroundColor Yellow
git status -s

if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
    $dateStr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $CommitMessage = "update: sync LiMu notes $dateStr"
}

Write-Host ">>> Staging and committing: $CommitMessage" -ForegroundColor Cyan
git add -A
git commit -m $CommitMessage

Write-Host ">>> Pushing to GitHub..." -ForegroundColor Cyan
git push origin main

Write-Host ">>> Push completed! GitHub repo: https://github.com/YanXu344/PythonProject" -ForegroundColor Green
