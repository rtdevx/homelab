<#
    .SYNOPSIS
    PowerShell script designed to automate the installation of Nerd Fonts on your system.

    Original Repository: https://github.com/amnweb/Nerd-Fonts-PowerShell-Installer
    Nerd Fonts: https://www.nerdfonts.com/
 
    .DESCRIPTION
    Nerd Fonts patches developer targeted fonts with a high number of glyphs (icons). 
    Specifically to add a high number of extra glyphs from popular ‘iconic fonts’ such as 
    Font Awesome, Devicons, Octicons, and others.

    Original Repository allows installation of multiple fonts selected in a pop up window. 
    For my use case, I only require a single font to be installed so this feature is disabled and a single font is selected.

    .USAGE
    1. Change $Font variable to mach the font you want to install (https://www.nerdfonts.com/)
    2. Run with PowerShell: ./NerdFonts-Install.ps1

#>

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
$Font = "FiraCode"

function Get-InstalledFonts {
    <#
    .SYNOPSIS
    This function retrieves information about fonts installed on the system.
    
    .DESCRIPTION
    This function uses the System.Drawing.Text.InstalledFontCollection class to retrieve information about 
    fonts installed on the system. It returns an array of objects, where each object represents a font and 
    contains the font name, font family, font type, and the font file name.
    
    .EXAMPLE
    Get-InstalledFonts
    
    This example retrieves information about all fonts installed on the system.
    
    .NOTES
    Author: CodePal
    #>
    
    try {
        # Create an instance of the InstalledFontCollection class
        $fontCollection = New-Object System.Drawing.Text.InstalledFontCollection
        
        # Get an array of FontFamily objects
        $fontFamilies = $fontCollection.Families
        
        # Create an empty array to store font information
        $fonts = @()
        
        # Loop through each FontFamily object and retrieve font information
        foreach ($fontFamily in $fontFamilies) {
            # Get the font name
            $fontName = $fontFamily.Name
            
            # Get the font type
            $fontType = $fontFamily.IsStyleAvailable("Regular")
            if ($fontType) {
                $fontType = "TrueType"
            }
            else {
                $fontType = "OpenType"
            }
            
            # Get the font file name
            $fontFile = $fontFamily.GetFiles()[0].Name
            
            # Create an object to store font information
            $font = [PSCustomObject]@{
                Name = $fontName
                Family = $fontFamily.Name
                Type = $fontType
                FileName = $fontFile
            }
            
            # Add the font object to the array
            $fonts += $font
        }
        
        # Return the array of font objects
        return $fonts
    }
    catch {
        # Log the error
        Write-Error $_.Exception.Message
        return $null
    }
}

Get-InstalledFonts
DownloadAndInstallFont $Font

