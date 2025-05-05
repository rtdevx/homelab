### Set up Windows Terminal ###

Function Starship {

#Install Nerd Fonts (source: https://www.nerdfonts.com/)
Write-Host `n"Installing Nerd Fonts."`n -ForegroundColor Green
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/WinBootstrap/Configurations/Install-NerdFonts.ps1'))

#Install Starhip Cross-Shell Prompt to start with Windows Terminal
Write-Host `n"Setting up Starship Terminal."`n -ForegroundColor Green

#PowerShell profile can be found under $PROFILE. PowerShell and PowerShell ISE have slightly different profiles.
#If this script is being executed from PowerShell ISE, different $PROFILE will be updated.
#Enruring that only PowerShell Profile is updated.
#If(!(Test-Path -PathType Leaf $PROFILE)) { New-Item -ItemType File -Path $PROFILE }
$TerminalProfile = "$env:USERPROFILE\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

#If(!(Test-Path -PathType Leaf $TerminalProfile)) { New-Item -ItemType File -Path $TerminalProfile }
New-Item -ItemType File -Path $TerminalProfile --force

$Content = Get-Content $TerminalProfile
If(-not($Content | Select-String -Pattern "Invoke-Expression")) {
        
    Add-Content -Path $TerminalProfile -Value "Invoke-Expression (&starship init powershell)"

} else { Write-Host "Starship profile was already configured here." -ForegroundColor Yellow }

#Add shell icons (source:https://www.hanselman.com/blog/my-ultimate-powershell-prompt-with-oh-my-posh-and-the-windows-terminal)
Write-Host `n"Adding shell icons."`n -ForegroundColor Green
If(-not($Content | Select-String -Pattern "Terminal-Icons")) {
        
    Add-Content -Path $TerminalProfile -Value "Install-Module -Name Terminal-Icons -Repository PSGallery -Force"
    Add-Content -Path $TerminalProfile -Value "Import-Module -Name Terminal-Icons -Force"

} else { Write-Host "Terminal-Icons are already installed. Skipping." -ForegroundColor Yellow }

#Enable IntelliSense (source: https://learn.microsoft.com/en-us/powershell/module/psreadline/about/about_psreadline)
Write-Host `n"Enabling IntelliSense in Windows Terminal."`n -ForegroundColor Green
If(-not($Content | Select-String -Pattern "PSReadLine")) {
        
    Add-Content -Path $TerminalProfile -Value "Install-Module -Name PSReadLine -Force"
    Add-Content -Path $TerminalProfile -Value "Import-Module PSReadLine -Force"
    Add-Content -Path $TerminalProfile -Value "Set-PSReadLineOption -PredictionSource History"
    
} else { Write-Host "Intellisense is already installed. Skipping." -ForegroundColor Yellow }

#Get-Content $PROFILE
Get-Content $TerminalProfile

#Apply Starship Configuration
If(!(Test-Path -PathType container $env:USERPROFILE\.config)) { New-Item -ItemType Directory -Path $env:USERPROFILE\.config } 
Write-Host `n"Applying Starship Settings."`n -ForegroundColor Green
Invoke-WebRequest -Uri https://raw.githubusercontent.com/rtdevx/dotfiles/refs/heads/main/terminal/starship.toml -OutFile $env:USERPROFILE\.config\starship.toml

}

Starship

#Apply Windows Terminal Settings
Write-Host `n"Applying Windows Terminal Settings."`n -ForegroundColor Green
Invoke-WebRequest -Uri https://raw.githubusercontent.com/rtdevx/dotfiles/refs/heads/main/terminal/WindowsTerminal.json -OutFile $env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
#More Windows Terminal Themes: https://windowsterminalthemes.dev/
