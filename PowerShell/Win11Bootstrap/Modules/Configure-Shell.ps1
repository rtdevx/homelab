# ------------------------------------------------------------
# Install Nerd Fonts (deterministic, quiet, idempotent)
# ------------------------------------------------------------
Write-Log "Ensuring Nerd Fonts are installed..."

$FontName = "Hack"
$FontVersion = "3.2.1"   # Update this when you want to force a reinstall
$FontTag = "v$FontVersion"
$FontZip = "$env:TEMP\HackNerdFont.zip"
$FontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$VersionFile = Join-Path $FontDir "HackNerdFont.version"

# Ensure font directory exists
if (-not (Test-Path $FontDir)) {
    New-Item -ItemType Directory -Path $FontDir -Force | Out-Null
}

# Check if version matches
$NeedsInstall = $true
if (Test-Path $VersionFile) {
    $InstalledVersion = Get-Content $VersionFile -ErrorAction SilentlyContinue
    if ($InstalledVersion -eq $FontVersion) {
        $NeedsInstall = $false
        Write-Log "Nerd Fonts already installed (version $FontVersion)"
    }
}

if ($NeedsInstall) {
    Write-Log "Downloading Nerd Font: $FontName $FontVersion"

    $DownloadUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/$FontTag/$FontName.zip"

    Invoke-WebRequest -Uri $DownloadUrl -OutFile $FontZip -UseBasicParsing

    Write-Log "Extracting Nerd Font..."
    Expand-Archive -Path $FontZip -DestinationPath $FontDir -Force

    # Write version file
    Set-Content -Path $VersionFile -Value $FontVersion -Encoding ASCII -Force

    # Cleanup
    Remove-Item $FontZip -Force

    Write-Log "Nerd Font installed (version $FontVersion)"
}
