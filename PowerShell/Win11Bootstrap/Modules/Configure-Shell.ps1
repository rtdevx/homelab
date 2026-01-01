<#
    Configure-Shell.ps1
    Deterministic PowerShell 7 shell setup:
    - Nerd Fonts
    - Starship
    - PowerShell 7 profile
    - Windows Terminal settings
    - Module installation (PSReadLine, Terminal-Icons)
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
# Install required modules for PowerShell 7
# ------------------------------------------------------------
Write-Log "Ensuring required PowerShell 7 modules are installed..."

$RequiredModules = @(
    "PSReadLine",
    "Terminal-Icons"
)

foreach ($Module in $RequiredModules) {
    if (-not (Get-Module -ListAvailable -Name $Module)) {
        Write-Log "Installing module: $Module"
        Install-Module $Module -Scope CurrentUser -Force -AllowClobber
    } else {
        Write-Log "Module already installed: $Module"
    }
}

# ------------------------------------------------------------
# Install Nerd Fonts (hash-based, deterministic, idempotent)
# ------------------------------------------------------------
Write-Log "Ensuring Nerd Fonts are installed..."

$FontName = "Hack"
$DownloadUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FontName.zip"

$FontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$ZipPath = "$env:TEMP\HackNerdFont.zip"
$HashFile = Join-Path $FontDir "HackNerdFont.hash"

# Ensure font directory exists
if (-not (Test-Path $FontDir)) {
    New-Item -ItemType Directory -Path $FontDir -Force | Out-Null
}

# Download ZIP to temp
Write-Log "Downloading Nerd Font ZIP metadata..."
Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipPath -UseBasicParsing

# Compute hash of downloaded ZIP
$NewHash = (Get-FileHash -Path $ZipPath -Algorithm SHA256).Hash

# Check if hash matches previous installation
$NeedsInstall = $true
if (Test-Path $HashFile) {
    $OldHash = Get-Content $HashFile -ErrorAction SilentlyContinue
    if ($OldHash -eq $NewHash) {
        $NeedsInstall = $false
        Write-Log "Nerd Fonts already up to date (hash match)"
    }
}

if ($NeedsInstall) {
    Write-Log "Installing Nerd Fonts (hash changed)..."

    # Extract ZIP into font directory
    Expand-Archive -Path $ZipPath -DestinationPath $FontDir -Force

    # Save new hash
    Set-Content -Path $HashFile -Value $NewHash -Encoding ASCII -Force

    Write-Log "Nerd Fonts installed successfully"
}

# Cleanup
Remove-Item $ZipPath -Force

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
