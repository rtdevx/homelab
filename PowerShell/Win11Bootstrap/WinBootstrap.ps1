# ------------------------------------------------------------
# 1. Logging (Rolling log setup (in-place, max 10 MB)
# ------------------------------------------------------------

$logRoot = "C:\Logs"
$logFile = Join-Path $logRoot "WinBootstrap.log"
$maxSizeBytes = 10MB

# Ensure log directory exists
if (-not (Test-Path $logRoot)) {
    New-Item -ItemType Directory -Path $logRoot | Out-Null
}

# If log file exists and exceeds max size, truncate it
if (Test-Path $logFile) {
    $size = (Get-Item $logFile).Length
    if ($size -gt $maxSizeBytes) {
        # Overwrite file with empty content
        Set-Content -Path $logFile -Value "" -Encoding UTF8
    }
}

# Start transcript logging (append to existing file)
Start-Transcript -Path $logFile -Append -Force

# ------------------------------------------------------------
# 2. Call Modules
# ------------------------------------------------------------

$BootstrapRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load helpers
. "$BootstrapRoot/Modules/Helpers.ps1"

Write-Host "=== Starting Windows Bootstrap ==="

Invoke-Module "Configure-Windows"
Invoke-Module "Install-WingetApps"
Invoke-Module "Install-StoreApps"
Invoke-Module "Configure-Shell"
Invoke-Module "Setup-GitHub"
Invoke-Module "Install-VSCodeExtensions"
Invoke-Module "Configure-Privacy"

Write-Host "=== Bootstrap Complete ==="

# Stop transcript
Stop-Transcript