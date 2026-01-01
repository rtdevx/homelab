<#
    Install-Starship.ps1
    Installs and configures the Starship prompt for PowerShell.
    Supports:
      - Nerd Fonts installation (via Install-NerdFonts.ps1)
      - PowerShell profile injection
      - PSReadLine IntelliSense configuration
      - Clean logging
#>

Write-Log "Starting Starship installation..."

# ------------------------------------------------------------
# Install Nerd Fonts (config-driven)
# ------------------------------------------------------------
try {
    Write-Log "Installing Nerd Fonts..."
    Invoke-Module "Install-NerdFonts"
    Write-Log "Nerd Fonts installation complete."
}
catch {
    Write-Log "Failed to install Nerd Fonts: $($_.Exception.Message)" "ERROR"
}

# ------------------------------------------------------------
# Install Starship (winget)
# ------------------------------------------------------------
Write-Log "Checking if Starship is already installed..."

$installed = winget list --id Starship.Starship --exact --source winget 2>$null
$hasHeader = $installed -match "Name\s+Id\s+Version"
$notInstalledMessage = $installed -match "No installed package"

if ($hasHeader -and -not $notInstalledMessage) {
    Write-Log "Starship is already installed."
} else {
    Write-Log "Installing Starship..."
    try {
        winget install --id Starship.Starship --silent --accept-package-agreements --accept-source-agreements
        Write-Log "Starship installed successfully."
    }
    catch {
        Write-Log "Failed to install Starship: $($_.Exception.Message)" "ERROR"
    }
}

# ------------------------------------------------------------
# Configure PowerShell profile
# ------------------------------------------------------------
Write-Log "Configuring PowerShell profile for Starship..."

$profilePath = $PROFILE
$profileDir = Split-Path $profilePath

if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$profileContent = ""
if (Test-Path $profilePath) {
    $profileContent = Get-Content $profilePath -Raw
}

if ($profileContent -notmatch "Invoke-Expression\s+\(starship init powershell\)") {
    Add-Content -Path $profilePath -Value "`n# Initialize Starship prompt`nInvoke-Expression (starship init powershell)`n"
    Write-Log "Added Starship initialization to PowerShell profile."
} else {
    Write-Log "Starship initialization already present in PowerShell profile."
}

# ------------------------------------------------------------
# Configure PSReadLine (IntelliSense + history)
# ------------------------------------------------------------
Write-Log "Configuring PSReadLine predictive IntelliSense..."

try {
    Add-Content -Path $profilePath -Value @"
# PSReadLine configuration
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
"@
    Write-Log "PSReadLine IntelliSense configured."
}
catch {
    Write-Log "Failed to configure PSReadLine: $($_.Exception.Message)" "ERROR"
}

# ------------------------------------------------------------
# Ensure starship.toml exists
# ------------------------------------------------------------
Write-Log "Ensuring starship.toml exists..."

$starshipConfigDir = Join-Path $env:USERPROFILE ".config"
$starshipConfigPath = Join-Path $starshipConfigDir "starship.toml"

if (-not (Test-Path $starshipConfigDir)) {
    New-Item -ItemType Directory -Path $starshipConfigDir -Force | Out-Null
}

if (-not (Test-Path $starshipConfigPath)) {
    @"
# Starship configuration
add_newline = true

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"

[package]
disabled = false
"@ | Set-Content -Path $starshipConfigPath -Encoding UTF8

    Write-Log "Created default starship.toml."
} else {
    Write-Log "starship.toml already exists."
}

Write-Log "Starship installation and configuration complete."
