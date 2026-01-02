<#
    Setup-Obsidian-Hugo.ps1
    One-off helper to prepare Hugo site repo for Obsidian + Git plugin workflow.

    Execution: `Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/Win11Bootstrap/Setup-Obsidian-Hugo.ps1' | Invoke-Expression`
#>

Write-Host "=== Setup-Obsidian-Hugo starting ==="

# Root path for Obsidian Git content
$obsidianGitRoot = Join-Path $env:USERPROFILE "Documents\Documents\Notes\Obsidian\Zettelkasten\Content Creation\Git"
$repoName        = "rtdevx.github.io"
$repoUrl         = "git@github.com:rtdevx/rtdevx.github.io.git"
$themePath       = "themes\congo"
$themeUrl        = "https://github.com/jpanther/congo.git"
$themeBranch     = "stable"

# ------------------------------------------------------------
# Ensure root path exists
# ------------------------------------------------------------
if (-not (Test-Path $obsidianGitRoot)) {
    Write-Host "Creating Obsidian Git root: $obsidianGitRoot"
    New-Item -Path $obsidianGitRoot -ItemType Directory -Force | Out-Null
}

Set-Location $obsidianGitRoot
Write-Host "Working in: $(Get-Location)"

# ------------------------------------------------------------
# Reset rtdevx.github.io repo
# ------------------------------------------------------------
$repoPath = Join-Path $obsidianGitRoot $repoName

if (Test-Path $repoPath) {
    Write-Host "Removing existing repo at: $repoPath"
    Remove-Item $repoPath -Force -Recurse
}

Write-Host "Cloning $repoUrl into $repoPath..."
git clone $repoUrl $repoPath

Set-Location $repoPath
Write-Host "Now in repo: $(Get-Location)"

# ------------------------------------------------------------
# Reset / re-add Congo theme as submodule
# ------------------------------------------------------------
$fullThemePath = Join-Path $repoPath $themePath

if (Test-Path $fullThemePath) {
    Write-Host "Removing existing theme directory: $fullThemePath"
    Remove-Item $fullThemePath -Force -Recurse
}

Write-Host "Removing theme from git index (if present)..."
git rm -r --cached $themePath 2>$null

Write-Host "Adding Congo theme as submodule..."
git submodule add -b $themeBranch $themeUrl $themePath

# ------------------------------------------------------------
# Optional: run Hugo server
# ------------------------------------------------------------
Write-Host "Starting Hugo server with drafts enabled (hugo server -D)..."
hugo server -D

Write-Host "=== Setup-Obsidian-Hugo completed ==="