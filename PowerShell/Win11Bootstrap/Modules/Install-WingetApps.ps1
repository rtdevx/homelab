<#
    Install-WingetApps.ps1
    Installs applications defined in Config/apps.json using winget.
    Supports:
      - groups
      - dependencies
      - version pinning
      - deduplication
#>

Write-Log "Starting Winget application installation..."

# ------------------------------------------------------------
# Refresh PATH for current session
# ------------------------------------------------------------
function Refresh-Path {
    $machine = [System.Environment]::GetEnvironmentVariable("Path","Machine")
    $user    = [System.Environment]::GetEnvironmentVariable("Path","User")

    $combined = @($machine, $user) -join ";"
    $env:Path = ($combined -split ";" | Where-Object { $_ -ne "" }) -join ";"

    Write-Log "PATH refreshed for current session."
}

# ------------------------------------------------------------
# Load configuration
# ------------------------------------------------------------
$configPath = Join-Path $BootstrapRoot "Config/apps.json"

if (-not (Test-Path $configPath)) {
    Write-Log "Config file not found: $configPath" "ERROR"
    return
}

try {
    $config = Get-Content $configPath | ConvertFrom-Json
} catch {
    Write-Log "Failed to parse apps.json: $($_.Exception.Message)" "ERROR"
    return
}

# ------------------------------------------------------------
# Select groups to install
# ------------------------------------------------------------
$selectedGroups = @("core", "dev", "ops", "personal")

# ------------------------------------------------------------
# Flatten selected groups into a single list
# ------------------------------------------------------------
$apps = foreach ($group in $selectedGroups) {
    if ($config.groups.PSObject.Properties.Name -contains $group) {
        $config.groups.$group
    } else {
        Write-Log "Group not found in config: $group" "WARN"
    }
}

# ------------------------------------------------------------
# Deduplicate apps by ID
# ------------------------------------------------------------
$apps = $apps | Where-Object { $_ -ne $null }

$apps = $apps | Group-Object id | ForEach-Object {
    $_.Group[0]  # keep first occurrence
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
# Install each app
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

    # Winget detection (exact match)
    $installed = winget list --id $id --exact --source winget 2>$null

    $hasHeader = $installed -match "Name\s+Id\s+Version"
    $notInstalledMessage = $installed -match "No installed package"

    if ($hasHeader -and -not $notInstalledMessage) {
        Write-Log "Already installed: $name"
        continue
    }

    Write-Log "Installing: $name ($id)"

    try {
        $args = @(
            "install", "--id", $id,
            "--silent",
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

Write-Log "Winget application installation complete."

# ------------------------------------------------------------
# Refresh PATH so newly installed apps are immediately available
# ------------------------------------------------------------
Refresh-Path

Write-Log "Winget application installation complete."