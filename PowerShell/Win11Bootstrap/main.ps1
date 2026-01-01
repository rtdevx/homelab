# =====================================================================
#  WinBootstrap Thin Loader
#  Downloads and executes the full bootstrap bundle from GitHub.
# =====================================================================

Write-Host "=== WinBootstrap Loader ==="

# ------------------------------------------------------------
# Elevation check
# ------------------------------------------------------------
$identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
$IsAdmin   = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "This script must be run as Administrator." -ForegroundColor Yellow
    return
}

# ------------------------------------------------------------
# 1. Environment Sanity Checks
# ------------------------------------------------------------

if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "PowerShell 5.0 or higher is required. Aborting."
    return
}

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
# 3. Download and Extract Bootstrap Bundle
# ------------------------------------------------------------

$ZipUrl = "https://github.com/rtdevx/homelab/archive/refs/heads/main.zip"
$TempRoot = Join-Path $env:TEMP "WinBootstrap"
$ZipPath = Join-Path $TempRoot "bootstrap.zip"

# Clean previous temp folder
if (Test-Path $TempRoot) {
    Remove-Item $TempRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $TempRoot | Out-Null

Write-Host "Downloading bootstrap bundle..."
try {
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Error "Failed to download bootstrap bundle: $($_.Exception.Message)"
    return
}

Write-Host "Extracting bootstrap bundle..."
Add-Type -AssemblyName System.IO.Compression.FileSystem
try {
    Expand-Archive -Path $ZipPath -DestinationPath $TempRoot -Force
} catch {
    Write-Error "Failed to extract bootstrap bundle: $($_.Exception.Message)"
    return
}

# ------------------------------------------------------------
# 4. Locate Win11Bootstrap Folder
# ------------------------------------------------------------

$BootstrapFolder = Join-Path $TempRoot "homelab-main\PowerShell\Win11Bootstrap"

if (-not (Test-Path $BootstrapFolder)) {
    Write-Error "Bootstrap folder not found inside extracted archive."
    return
}

$BootstrapScript = Join-Path $BootstrapFolder "WinBootstrap.ps1"

if (-not (Test-Path $BootstrapScript)) {
    Write-Error "WinBootstrap.ps1 not found in bootstrap folder."
    return
}

# ------------------------------------------------------------
# 5. Execute Bootstrap Script
# ------------------------------------------------------------

Write-Host "Executing bootstrap script..."
try {
    & $BootstrapScript
} catch {
    Write-Error "Bootstrap script execution failed: $($_.Exception.Message)"
    return
}
