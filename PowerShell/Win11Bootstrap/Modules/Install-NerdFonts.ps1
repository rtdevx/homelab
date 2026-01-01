<#
    Install-NerdFonts.ps1
    Installs one or more Nerd Fonts for the current user.
    Supports:
      - clean logging
      - idempotent installation
      - multiple fonts
      - silent operation
#>

Write-Log "Starting Nerd Fonts installation..."

# ------------------------------------------------------------
# Function: Download and install a single Nerd Font
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

    # Create destination folder
    if (-not (Test-Path $DestinationFolder)) {
        New-Item -ItemType Directory -Path $DestinationFolder -Force | Out-Null
    }

    try {
        Write-Log "Downloading $FontName from GitHub..."
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
# Fonts to install (config-driven in the future)
# ------------------------------------------------------------
$FontsToInstall = @(
    "Hack"
)

foreach ($font in $FontsToInstall) {
    Install-NerdFont -FontName $font
}

Write-Log "Nerd Fonts installation complete."
