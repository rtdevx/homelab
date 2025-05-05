### Install Nerd Fonts ###

function DownloadAndInstallFont {
    param(
        [Parameter(Mandatory=$true)]
        [string]$fontName
    )
    $url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/{0}.zip" -f $fontName
    $LocalAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::LocalApplicationData)
    $DestinationFolder = Join-Path -Path $LocalAppData -ChildPath "Microsoft\Windows\Fonts\$fontName"
    $Temp = $env:TEMP

    # Create the destination folder if it doesn't exist
    if (-not (Test-Path $DestinationFolder)) {
        New-Item -ItemType Directory -Path $DestinationFolder | Out-Null
    }

    try {
            Write-Host "Downloading $fontName..." -ForegroundColor Cyan
            Invoke-WebRequest -Uri $url -OutFile "$Temp\$fontName.zip"

            Write-Host "Extracting $fontName..." -ForegroundColor DarkCyan
            Expand-Archive -Path "$Temp\$fontName.zip" -DestinationPath $DestinationFolder -Force

            $fontFiles = Get-ChildItem -Path $DestinationFolder -Include '*.ttf', '*.otf' -Recurse
            $fileCount = $fontFiles.Count
            $counter = 1
            foreach ($file in $fontFiles) {
                $fontFilePath = $file.FullName
                $fontFileName = $file.Name
                
                # Register the font for the current user by adding it to the registry
                $fontsRegPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
                $null = Set-ItemProperty -Path $fontsRegPath -Name $fontFileName -Value $fontFilePath
                Write-Host "-Installed ($counter/$fileCount)" -ForegroundColor White
                Start-Sleep -Milliseconds 100
                $counter++
            }
            Remove-Item -Path "$Temp\$fontName.zip" -Force
    } catch {
        Write-Error "An error occurred: $_"
    }
}

try {
    Write-Host "Fetching available Nerd Fonts..." -ForegroundColor Cyan
    
    # Get the latest release info using the GitHub API
    $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
    
    # Extract all assets and filter for .zip files only
    $fontsArray = $releaseInfo.assets | 
                 Where-Object { $_.name -like "*.zip" -and $_.name -notlike "*.tar.xz" } | 
                 ForEach-Object { 
                     # Extract font name without extension
                     $_.name -replace '\.zip$', ''
                 } | 
                 Sort-Object
                 
    if ($fontsArray.Count -eq 0) {
        Write-Host "No fonts found in the latest release." -ForegroundColor Red
        exit
    }
    
    Write-Host "Found $($fontsArray.Count) fonts available for installation." -ForegroundColor Green
}
catch {
    # An error occurred, likely due to a problem with the API request
    Write-Host "An error occurred while trying to fetch fonts from GitHub: $_" -ForegroundColor Red
    exit 
}

#Change $Font variable to mach the font you want to install (https://www.nerdfonts.com/)
$Font = "Hack"

DownloadAndInstallFont $Font