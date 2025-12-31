<#
    Helpers.ps1
    Shared utility functions for Win11Bootstrap modules.
#>

# ------------------------------------------------------------
# Write-Log
# Timestamped console logging with levels
# ------------------------------------------------------------
function Write-Log {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [ValidateSet("INFO","WARN","ERROR")][string]$Level = "INFO"
    )

    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $color = switch ($Level) {
        "INFO"  { "White" }
        "WARN"  { "Yellow" }
        "ERROR" { "Red" }
    }

    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

# ------------------------------------------------------------
# Invoke-Module
# Loads and executes a module from the Modules folder
# ------------------------------------------------------------
function Invoke-Module {
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )

    $modulePath = Join-Path $PSScriptRoot "Modules/$Name.ps1"

    if (-not (Test-Path $modulePath)) {
        Write-Log "Module not found: $modulePath" "ERROR"
        return
    }

    Write-Log "Loading module: $Name"
    . $modulePath
}

# ------------------------------------------------------------
# Refresh-Path
# Reload PATH after winget installs
# ------------------------------------------------------------
function Refresh-Path {
    Write-Log "Refreshing PATH environment variable"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
                ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

# ------------------------------------------------------------
# Test-IsAdmin
# Returns $true if running elevated
# ------------------------------------------------------------
function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ------------------------------------------------------------
# Assert-Command
# Ensures a required command exists
# ------------------------------------------------------------
function Assert-Command {
    param(
        [Parameter(Mandatory=$true)][string]$Command
    )

    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        Write-Log "Required command missing: $Command" "ERROR"
        throw "Missing command: $Command"
    }
}

# ------------------------------------------------------------
# Invoke-Download
# Download a file with retry logic
# ------------------------------------------------------------
function Invoke-Download {
    param(
        [Parameter(Mandatory=$true)][string]$Url,
        [Parameter(Mandatory=$true)][string]$OutFile,
        [int]$Retries = 3
    )

    for ($i = 1; $i -le $Retries; $i++) {
        try {
            Write-Log "Downloading: $Url (attempt $i)"
            Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -ErrorAction Stop
            return
        }
        catch {
            Write-Log "Download failed: $($_.Exception.Message)" "WARN"
            Start-Sleep -Seconds 2
        }
    }

    Write-Log "Failed to download after $Retries attempts: $Url" "ERROR"
    throw "Download failed: $Url"
}
