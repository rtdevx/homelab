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
if ($PSVersionTable.PSVersion.Major -lt 5) { Write-Error "PowerShell 5.0 or higher is required. Aborting." return }

# Execution policy check (warn only)
$policy = Get-ExecutionPolicy
if ($policy -in @("Restricted", "Undefined")) {
    Write-Warning "Execution policy is '$policy'. You may need to allow script execution."
}
