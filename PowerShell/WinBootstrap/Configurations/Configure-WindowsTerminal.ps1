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

#Get-Content $PROFILE
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