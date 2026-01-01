<#
    Configure-WindowsTerminal.ps1
    Applies Windows Terminal configuration from Config/terminal.json.
    Supports:
      - Nerd Font assignment
      - settings.json templating
      - backup of existing settings
      - clean logging
#>

Write-Log "Starting Windows Terminal configuration..."

# ------------------------------------------------------------
# Locate Windows Terminal settings.json
# ------------------------------------------------------------
$wtSettingsPath = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (-not (Test-Path $wtSettingsPath)) {
    Write-Log "Windows Terminal settings.json not found. Terminal may not be installed yet." "WARN"
    return
}

# ------------------------------------------------------------
# Load terminal.json (your template)
# ------------------------------------------------------------
$configPath = Join-Path $BootstrapRoot "Config/terminal.json"

if (-not (Test-Path $configPath)) {
    Write-Log "Config file not found: $configPath" "ERROR"
    return
}

try {
    $terminalConfig = Get-Content $configPath -Raw | ConvertFrom-Json -AsHashtable
} catch {
    Write-Log "Failed to parse terminal.json: $($_.Exception.Message)" "ERROR"
    return
}

# ------------------------------------------------------------
# Load Nerd Font name from fonts.json
# ------------------------------------------------------------
$fontsConfigPath = Join-Path $BootstrapRoot "Config/fonts.json"

if (Test-Path $fontsConfigPath) {
    try {
        $fontsConfig = Get-Content $fontsConfigPath -Raw | ConvertFrom-Json
        $fontName = $fontsConfig.fonts[0]  # first font is the primary
        Write-Log "Using Nerd Font for Terminal: $fontName"
    } catch {
        Write-Log "Failed to parse fonts.json: $($_.Exception.Message)" "WARN"
    }
} else {
    Write-Log "fonts.json not found - using default font." "WARN"
}

# ------------------------------------------------------------
# Inject Nerd Font into Terminal config
# ------------------------------------------------------------
if ($fontName) {
    if (-not $terminalConfig.profiles) {
        Write-Log "terminal.json missing 'profiles' section." "ERROR"
    } else {
        if (-not $terminalConfig.profiles.defaults) {
            $terminalConfig.profiles.defaults = @{}
        }

        # Ensure modern font schema exists
        if (-not $terminalConfig.profiles.defaults.font) {
            $terminalConfig.profiles.defaults.font = @{}
        }

        $terminalConfig.profiles.defaults.font.face = $fontName

        Write-Log "Applied Nerd Font to Terminal profiles.defaults."
    }
}

# ------------------------------------------------------------
# Backup existing settings.json
# ------------------------------------------------------------
$backupPath = "$wtSettingsPath.bak"

try {
    Copy-Item -Path $wtSettingsPath -Destination $backupPath -Force
    Write-Log "Backed up existing settings.json to: $backupPath"
} catch {
    Write-Log "Failed to back up settings.json: $($_.Exception.Message)" "ERROR"
}

# ------------------------------------------------------------
# Write new settings.json
# ------------------------------------------------------------
try {
    $json = $terminalConfig | ConvertTo-Json -Depth 20
    Set-Content -Path $wtSettingsPath -Value $json -Encoding UTF8
    Write-Log "Applied new Windows Terminal configuration."
} catch {
    Write-Log "Failed to write new settings.json: $($_.Exception.Message)" "ERROR"
}

Write-Log "Windows Terminal configuration complete."
