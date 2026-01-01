<#
    Configure-Shell.ps1
    A compact, deterministic setup for:
    - Nerd Fonts
    - Starship prompt
    - PowerShell profile
    - Windows Terminal settings
#>

Write-Log "=== Configuring Shell Environment ==="

# ------------------------------------------------------------
# Resolve user profile (works even when elevated)
# ------------------------------------------------------------
$UserProfile = (Get-ChildItem Env:USERPROFILE).Value
$ConfigDir   = Join-Path $UserProfile ".config"
$PSProfile   = Join-Path $UserProfile "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

# ------------------------------------------------------------
# Ensure .config exists
# ------------------------------------------------------------
if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
    Write-Log "Created: $ConfigDir"
}

# ------------------------------------------------------------
# Install Nerd Fonts
# ------------------------------------------------------------
Write-Log "Installing Nerd Fonts..."
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString(
    'https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/WinBootstrap/Configurations/Install-NerdFonts.ps1'
))

# ------------------------------------------------------------
# Overwrite PowerShell profile (deterministic)
# ------------------------------------------------------------
Write-Log "Writing deterministic PowerShell profile..."

@'
# ============================================================
# Deterministic PowerShell Profile (managed by WinBootstrap)
# ============================================================

# --- PSReadLine ------------------------------------------------
Import-Module PSReadLine -Force
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -Font "Hack Nerd Font"

# --- Terminal Icons -------------------------------------------
Import-Module Terminal-Icons

# --- Starship Prompt ------------------------------------------
Invoke-Expression (& starship init powershell)
'@ | Set-Content -Path $PSProfile -Encoding UTF8 -Force

Write-Log "PowerShell profile written to: $PSProfile"

# ------------------------------------------------------------
# Download Starship config
# ------------------------------------------------------------
Write-Log "Applying Starship configuration..."
Invoke-WebRequest `
    -Uri "https://raw.githubusercontent.com/rtdevx/dotfiles/refs/heads/main/terminal/starship.toml" `
    -OutFile "$ConfigDir\starship.toml" `
    -UseBasicParsing

# ------------------------------------------------------------
# Apply Windows Terminal settings
# ------------------------------------------------------------
$WTLocalState = Join-Path $UserProfile "AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"

Write-Log "Applying Windows Terminal settings..."

Invoke-WebRequest `
    -Uri "https://raw.githubusercontent.com/rtdevx/dotfiles/refs/heads/main/terminal/state.json" `
    -OutFile "$WTLocalState\state.json" `
    -UseBasicParsing

Invoke-WebRequest `
    -Uri "https://raw.githubusercontent.com/rtdevx/dotfiles/refs/heads/main/terminal/settings.json" `
    -OutFile "$WTLocalState\settings.json" `
    -UseBasicParsing

Write-Log "=== Shell configuration complete ==="

Write-Log "DEBUG: Writing starship.toml to: $ConfigDir\starship.toml"
Write-Log "DEBUG: UserProfile resolved to: $UserProfile"
Write-Log "DEBUG: starship.toml size: $((Get-Item "$ConfigDir\starship.toml").Length) bytes"

