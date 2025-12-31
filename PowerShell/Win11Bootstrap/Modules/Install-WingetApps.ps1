<#
    Install-WingetApps.ps1
    Installs applications defined in Config/apps.json using winget.
#>

Write-Log "Starting Winget application installation..."

# ------------------------------------------------------------
# Load configuration
# ------------------------------------------------------------
$configPath = Join-Path $BootstrapRoot "Config/apps.json"

if (-not (Test-Path $configPath)) {
    Write-Log "Config file not found: $configPath" "ERROR"
    return
}

try {
    $apps = Get-Content $configPath | ConvertFrom-Json
} catch {
    Write-Log "Failed to parse apps.json: $($_.Exception.Message)" "ERROR"
    return
}

# ------------------------------------------------------------
# Install each app
# ------------------------------------------------------------
foreach ($app in $apps) {

    $id = $app.id
    $name = $app.name

    if (-not $id) {
        Write-Log "Skipping entry with missing 'id' field." "WARN"
        continue
    }

    Write-Log "Checking installation status for: $name ($id)"

# Check if already installed (exact match)
$installed = winget list --id $id --exact --source winget 2>$null

# Winget returns a table header when installed
$hasHeader = $installed -match "Name\s+Id\s+Version"

# Winget returns this message when NOT installed
$notInstalledMessage = $installed -match "No installed package"

if ($hasHeader -and -not $notInstalledMessage) {
    Write-Log "Already installed: $name"
    continue
}

    Write-Log "Installing: $name ($id)"

    try {
        winget install --id $id --silent --accept-package-agreements --accept-source-agreements
        Write-Log "Installed: $name"
    } catch {
        Write-Log "Failed to install ${name}: $($_.Exception.Message)" "ERROR"
    }
}

Write-Log "Winget application installation complete."
