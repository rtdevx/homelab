<#
    Configure-WindowsTerminal.ps1
    - Loads Config/terminal.json as a template
    - Loads Config/terminal-profiles.json for deterministic profiles
    - Loads Config/fonts.json to pick a Nerd Font
    - Merges everything into a valid Windows Terminal settings.json
#>

Write-Log "Starting Windows Terminal configuration..."

# ------------------------------------------------------------
# Helper: Convert PSCustomObject tree to hashtables (PS 5.1 compatible)
# ------------------------------------------------------------
function ConvertTo-Hashtable {
    param([Parameter(Mandatory)][object]$InputObject)

    if ($InputObject -is [pscustomobject]) {
        $hash = @{}
        foreach ($prop in $InputObject.PSObject.Properties) {
            $hash[$prop.Name] = ConvertTo-Hashtable $prop.Value
        }
        return $hash
    }

    if ($InputObject -is [System.Collections.IDictionary]) {
        $hash = @{}
        foreach ($key in $InputObject.Keys) {
            $hash[$key] = ConvertTo-Hashtable $InputObject[$key]
        }
        return $hash
    }

    if ($InputObject -is [System.Collections.IEnumerable] -and -not ($InputObject -is [string])) {
        $list = @()
        foreach ($item in $InputObject) {
            $list += ConvertTo-Hashtable $item
        }
        return $list
    }

    return $InputObject
}

# ------------------------------------------------------------
# Resolve paths
# ------------------------------------------------------------
if (-not $BootstrapRoot) {
    Write-Log "BootstrapRoot is not set. Cannot locate config files." "ERROR"
    return
}

$terminalConfigPath  = Join-Path $BootstrapRoot "Config\terminal.json"
$profilesConfigPath  = Join-Path $BootstrapRoot "Config\terminal-profiles.json"
$fontsConfigPath     = Join-Path $BootstrapRoot "Config\fonts.json"

# ------------------------------------------------------------
# Load terminal.json (template)
# ------------------------------------------------------------
try {
    $terminalConfig = ConvertTo-Hashtable (Get-Content $terminalConfigPath -Raw | ConvertFrom-Json)
} catch {
    Write-Log "Failed to parse terminal.json: $($_.Exception.Message)" "ERROR"
    return
}

# ------------------------------------------------------------
# Load terminal-profiles.json (deterministic profiles)
# ------------------------------------------------------------
try {
    $profilesConfig = ConvertTo-Hashtable (Get-Content $profilesConfigPath -Raw | ConvertFrom-Json)
} catch {
    Write-Log "Failed to parse terminal-profiles.json: $($_.Exception.Message)" "ERROR"
    return
}

# ------------------------------------------------------------
# Load fonts.json and pick a Nerd Font
# ------------------------------------------------------------
$fontName = $null

if (Test-Path $fontsConfigPath) {
    try {
        $fonts = ConvertTo-Hashtable (Get-Content $fontsConfigPath -Raw | ConvertFrom-Json)
        if ($fonts -and $fonts.fonts -and $fonts.fonts.Count -gt 0) {
            $fontName = $fonts.fonts[0]
            Write-Log "Using Nerd Font for Terminal: $fontName"
        }
    } catch {
        Write-Log "Failed to parse fonts.json: $($_.Exception.Message)" "ERROR"
    }
}

# ------------------------------------------------------------
# Merge profiles into template
# ------------------------------------------------------------
$terminalConfig.profiles = $profilesConfig.profiles

# Inject Nerd Font into defaults
if ($fontName) {
    if (-not $terminalConfig.profiles.defaults.font) {
        $terminalConfig.profiles.defaults.font = @{}
    }
    $terminalConfig.profiles.defaults.font.face = $fontName
}

# ------------------------------------------------------------
# Resolve Windows Terminal settings path
# ------------------------------------------------------------
$wtPackageRoot = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$wtSettingsPath = Join-Path $wtPackageRoot "settings.json"

if (-not (Test-Path $wtPackageRoot)) {
    Write-Log "Windows Terminal LocalState folder not found at: $wtPackageRoot" "ERROR"
    return
}

# ------------------------------------------------------------
# Backup existing settings.json
# ------------------------------------------------------------
if (Test-Path $wtSettingsPath) {
    $backupPath = "$wtSettingsPath.bak"
    Copy-Item -Path $wtSettingsPath -Destination $backupPath -Force
    Write-Log "Backed up existing settings.json to: $backupPath"
}

# ------------------------------------------------------------
# Write new settings.json
# ------------------------------------------------------------
try {
    $jsonOut = $terminalConfig | ConvertTo-Json -Depth 20
    $jsonOut | Set-Content -Path $wtSettingsPath -Encoding UTF8
    Write-Log "Applied new Windows Terminal configuration."
} catch {
    Write-Log "Failed to write new settings.json: $($_.Exception.Message)" "ERROR"
    return
}

Write-Log "Windows Terminal configuration complete."
