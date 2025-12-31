# =====================================================================
#  WinBootstrap Thin Loader
#  Downloads and executes the main bootstrap script from GitHub
#  using a temporary file for easy debugging.
# =====================================================================

Write-Host "=== WinBootstrap Loader ==="

# ------------------------------------------------------------
# 1. Environment Sanity Checks
# ------------------------------------------------------------

# Ensure TLS 1.2+ for GitHub
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# PowerShell version check
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "PowerShell 5.0 or higher is required. Aborting."
    exit 1
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
    Write-Warning "winget not found. Attempting to install App Installer from Microsoft Store..."

    try {
        Start-Process "ms-windows-store://pdp/?productid=9NBLGGH4NNS1"
        Write-Host "Please install 'App Installer' from Microsoft Store, then re-run this script."
        exit 1
    } catch {
        Write-Error "Failed to open Microsoft Store for App Installer. Install manually and re-run."
        exit 1
    }
}

Write-Host "winget is available."
