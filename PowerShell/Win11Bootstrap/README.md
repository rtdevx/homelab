# Usage

After fresh Windows 11 have been installed...

## Manual Steps

1. Windows Update > Advanced options > Receive updated for other Microsoft products - set to ON
2. Apply Windows Updates
3. Log in to OneDrive
  a. Download the content to local drive
4. System > Advanced > Terminal > PowerShell
  a. Change execution policy to allow local PowerSHell scripts to run without signing - set to ON
  b. Enable Sudo - set to ON
5. System > Advanced > Terminal - select "Windows Terminal"

```PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```
## Execute PowerShell command

`sudo PowerShell -Command "Invoke-Expression (Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/Win11Bootstrap/main.ps1')"`

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
