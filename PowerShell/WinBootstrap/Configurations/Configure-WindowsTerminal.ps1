### Set up Windows Terminal ###

#Copy dotfile
#C:\Users\$env:UserName\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState

#Installing Nerd Fonts (source: https://www.nerdfonts.com/)
Write-Host `n"Installing Nerd Fonts."`n -ForegroundColor Green
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/WinBootstrap/Configurations/Install-NerdFonts.ps1'))

#Installing Starhip Cross-Shell Prompt to start with Windows Terminal
Write-Host `n"Setting up Starship Terminal."`n -ForegroundColor Green

If(!(Test-Path -PathType Leaf $PROFILE)) { New-Item -ItemType File -Path $PROFILE }

$Content = Get-Content $PROFILE
If(-not($Content | Select-String -Pattern "Invoke-Expression")) {
        
    Add-Content -Path $PROFILE -Value "Invoke-Expression (&starship init powershell)"

} else { Write-Host "Starship profile was already configured here." -ForegroundColor Yellow }

#Adding shell icons (source:https://www.hanselman.com/blog/my-ultimate-powershell-prompt-with-oh-my-posh-and-the-windows-terminal)
Write-Host `n"Adding shell icons."`n -ForegroundColor Green
If(-not($Content | Select-String -Pattern "Module")) {
        
    Add-Content -Path $PROFILE -Value "Install-Module -Name Terminal-Icons -Repository PSGallery -Force"
    Add-Content -Path $PROFILE -Value "Import-Module -Name Terminal-Icons -Force"

} else { Write-Host "Starship profile was already configured here." -ForegroundColor Yellow }

Get-Content $PROFILE

If(!(Test-Path -PathType container $env:USERPROFILE\.config)) { New-Item -ItemType Directory -Path $env:USERPROFILE\.config } 

Write-Host `n"Applying Starship Settings."`n -ForegroundColor Green
Invoke-WebRequest -Uri https://raw.githubusercontent.com/rtdevx/dotfiles/refs/heads/main/terminal/starship.toml -OutFile $env:USERPROFILE\.config\starship.toml

Write-Host `n"Applying Windows Terminal Settings."`n -ForegroundColor Green
Invoke-WebRequest -Uri https://raw.githubusercontent.com/rtdevx/dotfiles/refs/heads/main/terminal/WindowsTerminal.json -OutFile $env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json