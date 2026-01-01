<#
    Install-NerdFonts.ps1
    Installs Nerd Fonts listed in Config/fonts.json.
    Supports:
      - clean logging
      - idempotent installation
      - multiple fonts
      - silent operation
#>

Write-Log "Starting Nerd Fonts installation..."

# ------------------------------------------------------------
# Load configuration
# ------------------------------------------------------------
$configPath = Join-Path $BootstrapRoot "Config/fonts.json"

if (-not (Test-Path $configPath)) {
    Write-Log "Config file not found: $configPath" "ERROR"
    return
}

try {
    $config = Get-Content $configPath | ConvertFrom-Json
} catch {
    Write-Log "Failed to parse fonts.json: $($_.Exception.Message)" "ERROR"
    return
}

if (-not $config.fonts) {
    Write-Log "No 'fonts' array found in fonts.json" "ERROR"
    return
}

$FontsToInstall = $config.fonts | Where-Object { $_ -ne $null }

# ------------------------------------------------------------
# Function: Install a single Nerd Font
# ------------------------------------------------------------
function Install-NerdFont {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FontName
    )

    Write-Log "Installing Nerd Font: $FontName"

    $url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FontName.zip"
    $LocalAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::LocalApplicationData)
    $DestinationFolder = Join-Path $LocalAppData "Microsoft\Windows\Fonts\$FontName"
    $TempZip = Join-Path $env:TEMP "$FontName.zip"

    # Ensure destination folder exists
    if (-not (Test-Path $DestinationFolder)) {
        New-Item -ItemType Directory -Path $DestinationFolder -Force | Out-Null
    }

    try {
        Write-Log "Downloading $FontName..."
        Invoke-WebRequest -Uri $url -OutFile $TempZip -UseBasicParsing

        Write-Log "Extracting $FontName..."
        Expand-Archive -Path $TempZip -DestinationPath $DestinationFolder -Force

        # Register fonts
        $fontFiles = Get-ChildItem -Path $DestinationFolder -Include '*.ttf','*.otf' -Recurse
        $fontsRegPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"

        $counter = 1
        foreach ($file in $fontFiles) {
            $fontFileName = $file.Name
            $fontFilePath = $file.FullName

            Set-ItemProperty -Path $fontsRegPath -Name $fontFileName -Value $fontFilePath -Force
            Write-Log "Registered font ($counter/$($fontFiles.Count)): $fontFileName"
            $counter++
        }

        Write-Log "Successfully installed Nerd Font: $FontName"
    }
    catch {
        Write-Log "Failed to install $FontName: $($_.Exception.Message)" "ERROR"
    }
    finally {
        if (Test-Path $TempZip) {
            Remove-Item $TempZip -Force
        }
    }
}

# ------------------------------------------------------------
# Install all fonts from config
# ------------------------------------------------------------
foreach ($font in $FontsToInstall) {
    Install-NerdFont -FontName $font
}

Write-Log "Nerd Fonts installation complete."
