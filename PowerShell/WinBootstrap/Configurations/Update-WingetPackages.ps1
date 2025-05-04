Write-Host `n"Updating Winget Packages."`n -ForegroundColor Green
winget source update ; winget upgrade --all --accept-package-agreements --accept-source-agreements --silent