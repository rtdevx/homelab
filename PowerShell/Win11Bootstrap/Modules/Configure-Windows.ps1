<#
    Setup-GitHub.ps1
    Clones GitHub repositories defined in Config/github.json
#>

Write-Log "=== Setup-GitHub starting ==="

# ------------------------------------------------------------
# Load GitHub configuration
# ------------------------------------------------------------
$githubConfigPath = Join-Path $PSScriptRoot '..\Config\github.json' | Resolve-Path -ErrorAction SilentlyContinue

if (-not $githubConfigPath) {
    Write-Log "github.json not found. Skipping GitHub setup." "WARN"
    return
}

try {
    $githubConfig = Get-Content -Path $githubConfigPath -Raw | ConvertFrom-Json -ErrorAction Stop
    Write-Log "Loaded GitHub configuration from $githubConfigPath."
}
catch {
    Write-Log "Failed to parse github.json: $($_.Exception.Message)" "WARN"
    return
}

if (-not $githubConfig.Repositories -or $githubConfig.Repositories.Count -eq 0) {
    Write-Log "No repositories defined in github.json. Skipping GitHub setup." "INFO"
    return
}

# ------------------------------------------------------------
# Ensure Git root exists
# ------------------------------------------------------------
$GitRoot = Join-Path $env:USERPROFILE "GitHub"

if (-not (Test-Path $GitRoot)) {
    Write-Log "Creating Git root directory at $GitRoot..."
    New-Item -Path $GitRoot -ItemType Directory -Force | Out-Null
}

# ------------------------------------------------------------
# Clone repositories
# ------------------------------------------------------------
foreach ($repo in $githubConfig.Repositories) {

    if ([string]::IsNullOrWhiteSpace($repo)) {
        Write-Log "Skipping empty repository entry in github.json." "WARN"
        continue
    }

    $name = ($repo -split "/")[-1].Replace(".git","")
    $target = Join-Path $GitRoot $name

    if (Test-Path $target) {
        Write-Log "Repository '$name' already exists at $target. Skipping."
        continue
    }

    Write-Log "Cloning $repo into $target..."
    try {
        git clone $repo $target 2>&1 | Write-Log
        Write-Log "Successfully cloned $name."
    }
    catch {
        Write-Log "Failed to clone ${repo}: $($_.Exception.Message)" "WARN"
    }
}

Write-Log "=== Setup-GitHub completed ==="