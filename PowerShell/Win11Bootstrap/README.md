# Usage
After installing a fresh Windows 11 system, follow these steps to prepare the environment before running the bootstrap.

# Manual Steps

1. `Windows Update → Advanced options → Receive updates for other Microsoft products` → ON
2. Apply all Windows Updates
3. `Settings → System → Advanced → Terminal → PowerShell`
    - Allow local PowerShell scripts (Execution Policy)
    - Enable Sudo
5. `Settings → System → Advanced → Terminal`
    - Set default terminal to Windows Terminal

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

# Execute PowerShell Command

Run an elevated PowerShell session and execute:

```powershell
Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/Win11Bootstrap/main.ps1' | Invoke-Expression
```

This downloads the thin loader, installs prerequisites, fetches the full bootstrap bundle, and executes the orchestrator.`

# Architecture

```
PowerShell/
└── Win11Bootstrap/
    ├── main.ps1                        # Thin Loader (pre-checks, winget validation, bundle download, bootstrap execution)
    ├── WinBootstrap.ps1                # Main orchestrator (module loading, sequencing, logging)
    ├── Modules/
    │   ├── Install-WingetApps.ps1      # Group-based winget installer with dependency + version support
    │   ├── Install-VSCodeExtensions.ps1
    │   ├── Configure-Windows.ps1
    │   ├── Configure-WindowsTerminal.ps1
    │   ├── Configure-Privacy.ps1
    │   ├── Setup-GitHub.ps1
    │   ├── Setup-WSL.ps1
    │   ├── Setup-PowerPlan.ps1
    │   ├── Setup-SystemRestore.ps1
    │   └── Helpers.ps1                 # Shared functions (Write-Log, RefreshPath, module loader, etc.)
    └── Config/
        ├── apps.json                   # Winget package groups, dependencies, version pinning
        ├── vscode-extensions.json      # VS Code extension list (future module)
        ├── privacy.json                # Optional privacy configuration
        └── terminal.json               # Optional Windows Terminal configuration
```

# Key Features

## Thin Loader  
Downloads and extracts the bootstrap bundle, validates winget, and executes the orchestrator.

## Modular Architecture  
Each system configuration task is isolated in its own module for clarity and maintainability.

## Config‑Driven Design  
App lists, VS Code extensions, privacy settings, and terminal preferences are all externalized into JSON.

## Group‑Based App Installation  

`apps.json` supports:

- core
- dev
- ops
- personal
- dependency chains
- version pinning
- deduplication

## Dependency‑Aware Installer  
Ensures prerequisites (e.g., .NET Desktop Runtime 5 → Dell Display Manager) install in the correct order.

## Future‑Proof  
Easy to extend with new modules, new config files, or additional automation.
