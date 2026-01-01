<#
    Configure-PowerShellProfile.ps1
    - Installs deterministic PowerShell profile
    - Ensures PSReadLine uses correct Nerd Font
    - Ensures Starship initializes correctly
    - Overwrites any existing profile for consistency
#>

Write-Log "Starting PowerShell profile configuration..."

# ------------------------------------------------------------
# Resolve paths
# ------------------------------------------------------------
if (-not $BootstrapRoot) {
    Write-Log "BootstrapRoot is not set. Cannot locate config files." "ERROR"
    return
}

$sourceProfilePath = Join-Path $BootstrapRoot "Config\powershell-profile.ps1"

# Always resolve the REAL user profile, even when elevated
$UserProfile = (Get-ChildItem Env:USERPROFILE).Value

$targetProfileDir  = Join-Path $UserProfile "Documents\PowerShell"
$targetProfilePath = Join-Path $targetProfileDir "Microsoft.PowerShell_profile.ps1"

# ------------------------------------------------------------
# Ensure profile directory exists
# ------------------------------------------------------------
if (-not (Test-Path $targetProfileDir)) {
    try {
        New-Item -ItemType Directory -Path $targetProfileDir -Force | Out-Null
        Write-Log "Created directory: $targetProfileDir"
    } catch {
        Write-Log "Failed to create PowerShell profile directory: $($_.Exception.Message)" "ERROR"
        return
    }
}

# ------------------------------------------------------------
# Validate source file
# ------------------------------------------------------------
if (-not (Test-Path $sourceProfilePath)) {
    Write-Log "powershell-profile.ps1 not found at: $sourceProfilePath" "ERROR"
    return
}

# ------------------------------------------------------------
# Copy profile into place
# ------------------------------------------------------------
try {
    Copy-Item -Path $sourceProfilePath -Destination $targetProfilePath -Force
    Write-Log "Installed PowerShell profile to: $targetProfilePath"
} catch {
    Write-Log "Failed to install PowerShell profile: $($_.Exception.Message)" "ERROR"
    return
}

Write-Log "PowerShell profile configuration complete."
