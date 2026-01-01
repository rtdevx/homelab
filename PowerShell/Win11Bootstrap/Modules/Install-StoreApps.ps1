<#
    Install-StoreApps.ps1
    Installs Microsoft Store applications defined in Config/apps-store.json.
    Supports:
      - dependency ordering
      - version pinning
      - clean logging
#>

Write-Log "Starting Microsoft Store application installation..."

# ------------------------------------------------------------
# Load configuration
# ------------------------------------------------------------
$configPath = Join-Path $BootstrapRoot "Config/apps-store.json"

if (-not (Test-Path $configPath)) {
    Write-Log "Config file not found: $configPath" "ERROR"
    return
}

try {
    $config = Get-Content $configPath | ConvertFrom-Json
} catch {
    Write-Log "Failed to parse apps-store.json: $($_.Exception.Message)" "ERROR"
    return
}

if (-not $config.groups) {
    Write-Log "No 'groups' object found in apps-store.json" "ERROR"
    return
}

$selectedGroups = @("core", "media", "communication", "utilities")

$apps = foreach ($group in $selectedGroups) {
    if ($config.groups.PSObject.Properties.Name -contains $group) {
        $config.groups.$group
    } else {
        Write-Log "Group not found in config: $group" "WARN"
    }
}

$apps = $apps | Where-Object { $_ -ne $null }

# ------------------------------------------------------------
# Deduplicate apps by ID
# ------------------------------------------------------------
$apps = $apps | Group-Object id | ForEach-Object {
    $_.Group[0]
}

# ------------------------------------------------------------
# Dependency ordering (simple topological sort)
# ------------------------------------------------------------
function Resolve-AppOrder {
    param([array]$apps)

    $resolved = New-Object System.Collections.ArrayList
    $unresolved = New-Object System.Collections.ArrayList
    $appsById = @{}

    foreach ($app in $apps) {
        $appsById[$app.id] = $app
    }

    function Visit($app) {
        if ($resolved -contains $app) { return }
        if ($unresolved -contains $app) {
            Write-Log "Circular dependency detected for $($app.name)" "ERROR"
            return
        }

        $unresolved.Add($app) | Out-Null

        if ($app.dependsOn) {
            foreach ($depId in $app.dependsOn) {
                if ($appsById.ContainsKey($depId)) {
                    Visit $appsById[$depId]
                } else {
                    Write-Log "Missing dependency $depId for $($app.name)" "WARN"
                }
            }
        }

        $unresolved.Remove($app)
        $resolved.Add($app) | Out-Null
    }

    foreach ($app in $apps) {
        Visit $app
    }

    return $resolved
}

$apps = Resolve-AppOrder -apps $apps

# ------------------------------------------------------------
# Install each Store app
# ------------------------------------------------------------
foreach ($app in $apps) {

    $id = $app.id
    $name = $app.name
    $version = $app.version

    if (-not $id) {
        Write-Log "Skipping entry with missing 'id' field." "WARN"
        continue
    }

    Write-Log "Checking installation status for: $name ($id)"

    # Check if installed via Appx
    $installed = Get-AppxPackage -Name $id -ErrorAction SilentlyContinue

    if ($installed) {
        Write-Log "Already installed: $name"
        continue
    }

    Write-Log "Installing: $name ($id)"

    try {
        $args = @(
            "install", "--id", $id,
            "--source", "msstore",
            "--accept-package-agreements",
            "--accept-source-agreements"
        )

        if ($version) {
            $args += @("--version", $version)
        }

        winget @args
        Write-Log "Installed: $name"
    }
    catch {
        Write-Log "Failed to install ${name}: $($_.Exception.Message)" "ERROR"
    }
}

Write-Log "Microsoft Store application installation complete."
