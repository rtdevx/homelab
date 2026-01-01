$BootstrapRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load helpers
. "$BootstrapRoot/Modules/Helpers.ps1"

Write-Host "=== Starting Windows Bootstrap ==="

Invoke-Module "Configure-Windows"
Invoke-Module "Install-WingetApps"
Invoke-Module "Install-StoreApps"
Invoke-Module "Configure-Shell"
Invoke-Module "Setup-GitHub"
Invoke-Module "Install-VSCodeExtensions"
Invoke-Module "Configure-Privacy"

Write-Host "=== Bootstrap Complete ==="
