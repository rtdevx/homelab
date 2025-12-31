# Usage

sudo PowerShell -Command "Invoke-Expression (Invoke-WebRequest 'https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/Win11Bootstrap/main.ps1')"

# Architecture

PowerShell/
└── WinBootstrap/
    ├── main.ps1                        # Thin Loader (installing pre-requisites, executing main bootstrap script)
    ├── WinBootstrap.ps1                # Main orchestrator
    ├── Modules/
    │   ├── Install-WingetApps.ps1
    │   ├── Install-VSCodeExtensions.ps1
    │   ├── Configure-Windows.ps1
    │   ├── Configure-WindowsTerminal.ps1
    │   ├── Configure-Privacy.ps1
    │   ├── Setup-GitHub.ps1
    │   ├── Setup-WSL.ps1
    │   ├── Setup-PowerPlan.ps1
    │   ├── Setup-SystemRestore.ps1
    │   └── Helpers.ps1                 # Shared functions (RefreshPath, logging, etc.)
    └── Config/
        ├── apps.json                   # Winget package list
        ├── vscode-extensions.json
        ├── privacy.json                # Optional future config
        └── terminal.json               # Optional future config
