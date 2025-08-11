Start-Transcript -Path $LogsFolder\Update-WingetPackages.log

Write-Host `n"Updating Winget Packages."`n -ForegroundColor Green
winget source update ; winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements --silent

Stop-Transcript