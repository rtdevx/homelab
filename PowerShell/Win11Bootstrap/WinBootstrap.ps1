$BootstrapRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load helpers
. "$BootstrapRoot/Modules/Helpers.ps1"

Write-Host "=== Starting Windows Bootstrap ==="

Invoke-Module "Setup-SystemRestore"
Invoke-Module "Install-WingetApps"
Invoke-Module "Install-StoreApps"
Invoke-Module "Install-VSCodeExtensions"
Invoke-Module "Setup-GitHub"
Invoke-Module "Configure-Windows"
#Invoke-Module "Configure-WindowsTerminal"
Invoke-Module "Configure-Privacy"
Invoke-Module "Setup-WSL"
Invoke-Module "Setup-PowerPlan"

Write-Host "=== Bootstrap Complete ==="
