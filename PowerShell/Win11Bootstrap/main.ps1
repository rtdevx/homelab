# =====================================================================
#  WinBootstrap Thin Loader
#  Downloads and executes the main bootstrap script from GitHub
#  using a temporary file for easy debugging.
# =====================================================================

Write-Host "=== WinBootstrap Loader ==="

# ------------------------------------------------------------
# 1. Environment Sanity Checks
# ------------------------------------------------------------

# PowerShell version check
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "PowerShell 5.0 or higher is required. Aborting."
    return
}

# Execution policy check (warn only)
$policy = Get-ExecutionPolicy
if ($policy -in @("Restricted", "Undefined")) {
    Write-Warning "Execution policy is '$policy'. You may need to allow script execution."
}

# ------------------------------------------------------------
# 2. Winget Health Check
# ------------------------------------------------------------

function Test-WinGet {
    try {
        winget --version | Out-Null
        return $true
    } catch {
        return $false
    }
}

Write-Host "Checking winget availability..."

if (-not (Test-WinGet)) {
    Write-Warning "winget not found. Attempting to open App Installer in Microsoft Store..."

    try {
        Start-Process "ms-windows-store://pdp/?productid=9NBLGGH4NNS1"
        Write-Host "Please install 'App Installer' from Microsoft Store, then re-run this script."
        return
    } catch {
        Write-Error "Failed to open Microsoft Store for App Installer. Install manually and re-run."
        return
    }
}

Write-Host "winget is available."

# ------------------------------------------------------------
# 3. Download Main Bootstrap Script
# ------------------------------------------------------------

$BootstrapUrl = "https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/Win11Bootstrap/WinBootstrap.ps1"
$TempFile = Join-Path $env:TEMP "WinBootstrap.ps1"

Write-Host "Downloading main bootstrap script..."
$maxRetries = 3
$success = $false

for ($i = 1; $i -le $maxRetries; $i++) {
    try {
        Invoke-WebRequest -Uri $BootstrapUrl -OutFile $TempFile -UseBasicParsing -ErrorAction Stop
        $success = $true
        break
    } catch {
        Write-Warning "Download attempt $i failed: $($_.Exception.Message)"
        Start-Sleep -Seconds 2
    }
}

if (-not $success) {
    Write-Error "Failed to download bootstrap script after $maxRetries attempts."
    return
}

Write-Host "Bootstrap script downloaded to: $TempFile"

# ------------------------------------------------------------
# 4. Execute Bootstrap Script
# ------------------------------------------------------------

try {
    Write-Host "Executing bootstrap script..."
    & $TempFile
} catch {
    Write-Error "Bootstrap script execution failed: $($_.Exception.Message)"
    Write-Warning "The temporary file has been preserved for debugging:"
    Write-Warning "  $TempFile"
    return
}

# ------------------------------------------------------------
# 5. Cleanup
# ------------------------------------------------------------

try {
    Remove-Item $TempFile -Force
    Write-Host "Temporary bootstrap file removed."
} catch {
    Write-Warning "Could not delete temporary file: $TempFile"
}

Write-Host "=== Bootstrap complete ==="
