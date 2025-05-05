### Set up Windows Terminal ###

Function Starship {

#Install Nerd Fonts (source: https://www.nerdfonts.com/)
Write-Host `n"Installing Nerd Fonts."`n -ForegroundColor Green
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/WinBootstrap/Configurations/Install-NerdFonts.ps1'))

#Install Starhip Cross-Shell Prompt to start with Windows Terminal
Write-Host `n"Setting up Starship Terminal."`n -ForegroundColor Green

#New-Item -ItemType File -Path $TerminalProfile -Force
New-Item -ItemType File -Path $PROFILE -Force

$Content = Get-Content $PROFILE
If(-not($Content | Select-String -Pattern "Invoke-Expression")) {
        
    Add-Content -Path $PROFILE -Value "Invoke-Expression (&starship init powershell)"

} else { Write-Host "Starship profile was already configured here." -ForegroundColor Yellow }

#Add shell icons 
Write-Host `n"Adding shell icons."`n -ForegroundColor Green
If(-not($Content | Select-String -Pattern "Terminal-Icons")) {
        
    Add-Content -Path $PROFILE -Value "Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser"
    Add-Content -Path $PROFILE -Value "Import-Module -Name Terminal-Icons"

} else { Write-Host "Terminal-Icons are already installed. Skipping." -ForegroundColor Yellow }

#Enable IntelliSense
Write-Host `n"Enabling IntelliSense in Windows Terminal."`n -ForegroundColor Green
If(-not($Content | Select-String -Pattern "PSReadLine")) {
        
    Add-Content -Path $PROFILE -Value "Install-Module -Name PSReadLine -Scope CurrentUser"
    Add-Content -Path $PROFILE -Value "Import-Module PSReadLine"
    Add-Content -Path $PROFILE -Value "Set-PSReadLineOption -PredictionSource History"
    
} else { Write-Host "Intellisense is already installed. Skipping." -ForegroundColor Yellow }

Get-Content $PROFILE

#Apply Starship Configuration
If(!(Test-Path -PathType container $env:USERPROFILE\.config)) { New-Item -ItemType Directory -Path $env:USERPROFILE\.config } 
Write-Host `n"Applying Starship Settings."`n -ForegroundColor Green
Invoke-WebRequest -Uri https://raw.githubusercontent.com/rtdevx/dotfiles/refs/heads/main/terminal/starship.toml -OutFile $env:USERPROFILE\.config\starship.toml

}

Starship

#Apply Windows Terminal Settings
Write-Host `n"Applying Windows Terminal Settings."`n -ForegroundColor Green
Invoke-WebRequest -Uri https://raw.githubusercontent.com/rtdevx/dotfiles/refs/heads/main/terminal/WindowsTerminal.json -OutFile $env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json

<#
# Define the path to the JSON file
$jsonPath = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Read and parse the JSON content
$jsonContent = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json

# Overwrite "profiles.defaults" section
$jsonContent.profiles.defaults = @{
    colorScheme = "ayu"
    cursorShape = "bar"
    "experimental.retroTerminalEffect" = $false
    font = @{ face = "Hack Nerd Font" }
    opacity = 0
    startingDirectory = "~"
    useAcrylic = $true
}

# Overwrite "profiles.list" section with updated details
$jsonContent.profiles.list = @(
    @{
        commandline = "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
        font = @{ face = "Hack Nerd Font" }
        guid = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}"
        hidden = $false
        name = "Windows PowerShell"
        opacity = 85
    }
)

# Replace "schemes" with the new schemes
$jsonContent.schemes = @(
    @{
        background = "#282C34"
        black = "#41444D"
        blue = "#3476FF"
        brightBlack = "#8F9AAE"
        brightBlue = "#10B1FE"
        brightCyan = "#5FB9BC"
        brightGreen = "#3FC56B"
        brightPurple = "#FF78F8"
        brightRed = "#FF6480"
        brightWhite = "#FFFFFF"
        brightYellow = "#F9C859"
        cursorColor = "#FFCC00"
        cyan = "#4483AA"
        foreground = "#B9C0CB"
        green = "#25A45C"
        name = "BlulocoDark"
        purple = "#7A82DA"
        red = "#FC2F52"
        selectionBackground = "#B9C0CA"
        white = "#CDD4E0"
        yellow = "#FF936A"
    },
    @{
        background = "#0F1419"
        black = "#000000"
        blue = "#36A3D9"
        brightBlack = "#323232"
        brightBlue = "#68D5FF"
        brightCyan = "#C7FFFD"
        brightGreen = "#EAFE84"
        brightPurple = "#FFA3AA"
        brightRed = "#FF6565"
        brightWhite = "#FFFFFF"
        brightYellow = "#FFF779"
        cursorColor = "#F29718"
        cyan = "#95E6CB"
        foreground = "#E6E1CF"
        green = "#B8CC52"
        name = "ayu"
        purple = "#F07178"
        red = "#FF3333"
        selectionBackground = "#253340"
        white = "#FFFFFF"
        yellow = "#E7C547"
    }
)

# Ensure "copyOnSelect" exists
$jsonContent.copyOnSelect = $true

# Convert back to JSON and save the updated content
$jsonContent | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonPath

Write-Host "Windows Terminal settings successfully updated!"
#>