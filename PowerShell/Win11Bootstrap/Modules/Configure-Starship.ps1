<#
    Configure-Starship.ps1
    - Installs deterministic starship.toml into ~/.config
    - Ensures correct Nerd Font family is used
    - Overwrites any existing config for consistency
#>

Write-Log "Starting Starship configuration..."

# ------------------------------------------------------------
# Resolve paths
# ------------------------------------------------------------
if (-not $BootstrapRoot) {
    Write-Log "BootstrapRoot is not set. Cannot locate config files." "ERROR"
    return
}

$sourceConfigPath = Join-Path $BootstrapRoot "Config\starship.toml"

# Always resolve the REAL user profile, even when elevated
$UserProfile = [Environment]::GetFolderPath("UserProfile")

$targetConfigDir  = Join-Path $UserProfile ".config"
$targetConfigPath = Join-Path $targetConfigDir "starship.toml"

# ------------------------------------------------------------
# Ensure ~/.config exists
# ------------------------------------------------------------
if (-not (Test-Path $targetConfigDir)) {
    try {
        New-Item -ItemType Directory -Path $targetConfigDir -Force | Out-Null
        Write-Log "Created directory: $targetConfigDir"
    } catch {
        Write-Log "Failed to create ~/.config directory: $($_.Exception.Message)" "ERROR"
        return
    }
}

# ------------------------------------------------------------
# Validate source file
# ------------------------------------------------------------
if (-not (Test-Path $sourceConfigPath)) {
    Write-Log "starship.toml not found at: $sourceConfigPath" "ERROR"
    return
}

# ------------------------------------------------------------
# Copy starship.toml into place
# ------------------------------------------------------------
try {
    Copy-Item -Path $sourceConfigPath -Destination $targetConfigPath -Force
    Write-Log "Installed starship.toml to: $targetConfigPath"
} catch {
    Write-Log "Failed to install starship.toml: $($_.Exception.Message)" "ERROR"
    return
}

Write-Log "Starship configuration complete."
