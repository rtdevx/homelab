<#
    Install-VSCodeExtensions.ps1
    Installs VS Code extensions defined in Config/vscode-extensions.json.
    Supports:
      - clean logging
      - deduplication
      - version pinning (optional)
#>

Write-Log "Starting VS Code extension installation..."

# ------------------------------------------------------------
# Load configuration
# ------------------------------------------------------------
$configPath = Join-Path $BootstrapRoot "Config/vscode-extensions.json"

if (-not (Test-Path $configPath)) {
    Write-Log "Config file not found: $configPath" "ERROR"
    return
}

try {
    $config = Get-Content $configPath | ConvertFrom-Json
} catch {
    Write-Log "Failed to parse vscode-extensions.json: $($_.Exception.Message)" "ERROR"
    return
}

if (-not $config.extensions) {
    Write-Log "No 'extensions' array found in vscode-extensions.json" "ERROR"
    return
}

$extensions = $config.extensions | Where-Object { $_ -ne $null }

# ------------------------------------------------------------
# Deduplicate extensions by ID
# ------------------------------------------------------------
$extensions = $extensions | Group-Object id | ForEach-Object {
    $_.Group[0]
}

# ------------------------------------------------------------
# Install each extension
# ------------------------------------------------------------
foreach ($ext in $extensions) {

    $id = $ext.id
    $name = $ext.name
    $version = $ext.version

    if (-not $id) {
        Write-Log "Skipping entry with missing 'id' field." "WARN"
        continue
    }

    Write-Log "Checking installation status for: $name ($id)"

    # Check if installed
    $installed = code --list-extensions | Select-String -Pattern "^$id$"

    if ($installed) {
        Write-Log "Already installed: $name"
        continue
    }

    Write-Log "Installing: $name ($id)"

    try {
        $args = @("--install-extension", $id, "--force")

        if ($version) {
            $args += @("--install-extension", "$id@$version")
        }

        Start-Process "code" -WindowStyle Hidden -ArgumentList $args -Wait
        Write-Log "Installed: $name"
    }
    catch {
        Write-Log "Failed to install ${name}: $($_.Exception.Message)" "ERROR"
    }
}

Write-Log "VS Code extension installation complete."