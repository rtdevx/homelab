<#
    Configure-WindowsTerminal.ps1
    - Loads Config/terminal.json as a template
    - Loads Config/fonts.json to pick a Nerd Font
    - Injects the font into profiles.defaults.font.face
    - Backs up existing Windows Terminal settings.json
    - Writes new settings.json
#>

Write-Log "Starting Windows Terminal configuration..."

# ------------------------------------------------------------
# Helper: Convert PSCustomObject tree to hashtables (PS 5.1 compatible)
# ------------------------------------------------------------
function ConvertTo-Hashtable {
    param(
        [Parameter(Mandatory)]
        [object]$InputObject
    )

    if ($InputObject -is [System.Collections.IDictionary]) {
        $hash = @{}
        foreach ($key in $InputObject.Keys) {
            $hash[$key] = ConvertTo-Hashtable $InputObject[$key]
        }
        return $hash
    }
    elseif ($InputObject -is [System.Collections.IEnumerable] -and
            -not ($InputObject -is [string])) {
        $list = @()
        foreach ($item in $InputObject) {
            $list += ConvertTo-Hashtable $item
        }
        return $list
    }
    else {
        return $InputObject
    }
}

# ------------------------------------------------------------
# Resolve paths
# ------------------------------------------------------------
if (-not $BootstrapRoot) {
    Write-Log "BootstrapRoot is not set. Cannot locate config files." "ERROR"
    return
}

$terminalConfigPath = Join-Path $BootstrapRoot "Config\terminal.json"
$fontsConfigPath    = Join-Path $BootstrapRoot "Config\fonts.json"

# ------------------------------------------------------------
# Load terminal.json
# ------------------------------------------------------------
if (-not (Test-Path $terminalConfigPath)) {
    Write-Log "terminal.json not found at: $terminalConfigPath" "ERROR"
    return
}

try {
    $terminalConfigRaw = Get-Content $terminalConfigPath -Raw
    $terminalConfigObj = $terminalConfigRaw | ConvertFrom-Json
    $terminalConfig    = ConvertTo-Hashtable $terminalConfigObj
} catch {
    Write-Log "Failed to parse terminal.json: $($_.Exception.Message)" "ERROR"
    return
}

# ------------------------------------------------------------
# Load fonts.json and pick a Nerd Font
# ------------------------------------------------------------
$fontName = $null

if (Test-Path $fontsConfigPath) {
    try {
        $fontsRaw = Get-Content $fontsConfigPath -Raw
        $fontsObj = $fontsRaw | ConvertFrom-Json
        $fonts    = ConvertTo-Hashtable $fontsObj

        if ($fonts -and $fonts.fonts -and $fonts.fonts.Count -gt 0) {
            # Pick the first font in the list for Terminal
            $fontName = $fonts.fonts[0]
            Write-Log "Using Nerd Font for Terminal: $fontName"
        } else {
            Write-Log "fonts.json found but no fonts defined. Using default Terminal font." "WARN"
        }
    } catch {
        Write-Log "Failed to parse fonts.json: $($_.Exception.Message)" "ERROR"
    }
} else {
    Write-Log "fonts.json not found. Using default Terminal font." "WARN"
}

# ------------------------------------------------------------
# Inject Nerd Font into profiles.defaults (modern schema)
# ------------------------------------------------------------
if ($fontName) {
    if (-not $terminalConfig.ContainsKey('profiles')) {
        Write-Log "terminal.json missing 'profiles' section." "ERROR"
    } else {
        # Ensure profiles is an object-like structure
        if ($terminalConfig.profiles -is [System.Collections.IEnumerable] -and
            -not ($terminalConfig.profiles -is [System.Collections.IDictionary])) {
            # If profiles is an array, wrap it in an object under 'list'
            $terminalConfig.profiles = @{ list = $terminalConfig.profiles }
        }

        if (-not $terminalConfig.profiles.ContainsKey('defaults')) {
            $terminalConfig.profiles.defaults = @{}
        }

        if (-not $terminalConfig.profiles.defaults.ContainsKey('font')) {
            $terminalConfig.profiles.defaults.font = @{}
        }

        $terminalConfig.profiles.defaults.font.face = $fontName

        Write-Log "Applied Nerd Font to Terminal profiles.defaults."
    }
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
# Backup existing settings.json (if present)
# ------------------------------------------------------------
if (Test-Path $wtSettingsPath) {
    $backupPath = "$wtSettingsPath.bak"
    try {
        Copy-Item -Path $wtSettingsPath -Destination $backupPath -Force
        Write-Log "Backed up existing settings.json to: $backupPath"
    } catch {
        Write-Log "Failed to back up existing settings.json: $($_.Exception.Message)" "ERROR"
    }
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
