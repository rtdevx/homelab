<#
    Configure-Shell.ps1
    Deterministic PowerShell 7 shell setup:
    - Nerd Fonts
    - Starship
    - PowerShell 7 profile
    - Windows Terminal settings
#>

Write-Log "=== Configuring Shell Environment ==="

# ------------------------------------------------------------
# Resolve user profile (interactive user, not elevated token)
# ------------------------------------------------------------
$UserProfile = [Environment]::GetFolderPath("UserProfile")
$ConfigDir   = Join-Path $UserProfile ".config"

# PowerShell 7 profile path
$PS7ProfileDir = Join-Path $UserProfile "Documents\PowerShell"
$PS7Profile    = Join-Path $PS7ProfileDir "Microsoft.PowerShell_profile.ps1"

# Legacy PowerShell 5.1 profile path
$PS51Dir = Join-Path $UserProfile "Documents\WindowsPowerShell"

# ------------------------------------------------------------
# Ensure .config exists
# ------------------------------------------------------------
if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
    Write-Log "Created: $ConfigDir"
}

# ------------------------------------------------------------
# Remove legacy WindowsPowerShell folder (PowerShell 5.1)
# ------------------------------------------------------------
if (Test-Path $PS51Dir) {
    Remove-Item $PS51Dir -Recurse -Force
    Write-Log "Removed legacy WindowsPowerShell profile directory: $PS51Dir"
}

# ------------------------------------------------------------
# Ensure PowerShell 7 profile directory exists
# ------------------------------------------------------------
if (-not (Test-Path $PS7ProfileDir)) {
    New-Item -ItemType Directory -Path $PS7ProfileDir -Force | Out-Null
    Write-Log "Created PowerShell 7 profile directory: $PS7ProfileDir"
}

# ------------------------------------------------------------
# Install Nerd Fonts
# ------------------------------------------------------------
Write-Log "Installing Nerd Fonts..."
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString(
    'https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/WinBootstrap/Configurations/Install-NerdFonts.ps1'
))

# ------------------------------------------------------------
# Write deterministic PowerShell 7 profile
# ------------------------------------------------------------
Write-Log "Writing deterministic PowerShell 7 profile..."

@'
# ============================================================
# Deterministic PowerShell 7 Profile (managed by WinBootstrap)
# ============================================================

Import-Module PSReadLine -Force
Set-PSReadLineOption -PredictionSource History

# Font is controlled by Windows Terminal, not PSReadLine

Import-Module Terminal-Icons

Invoke-Expression (& starship init powershell)
'@ | Set-Content -Path $PS7Profile -Encoding UTF8 -Force

Write-Log "PowerShell 7 profile written to: $PS7Profile"

# ------------------------------------------------------------
# Download Starship config
# ------------------------------------------------------------
Write-Log "Applying Starship configuration..."

Invoke-WebRequest `
    -Uri "https://raw.githubusercontent.com/rtdevx/dotfiles/main/terminal/starship.toml" `
    -OutFile "$ConfigDir\starship.toml" `
    -UseBasicParsing

# ------------------------------------------------------------
# Apply Windows Terminal settings
# ------------------------------------------------------------
$WTLocalState = Join-Path $UserProfile "AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"

Write-Log "Applying Windows Terminal settings..."

Invoke-WebRequest `
    -Uri "https://raw.githubusercontent.com/rtdevx/dotfiles/main/terminal/state.json" `
    -OutFile "$WTLocalState\state.json" `
    -UseBasicParsing

Invoke-WebRequest `
    -Uri "https://raw.githubusercontent.com/rtdevx/dotfiles/main/terminal/settings.json" `
    -OutFile "$WTLocalState\settings.json" `
    -UseBasicParsing

Write-Log "=== Shell configuration complete ==="
