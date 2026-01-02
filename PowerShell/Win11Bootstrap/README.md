# Windows 11 Bootstrap

This project automates the setup of a fresh Windows 11 system. It installs applications, configures the shell, applies system settings, sets up Git + SSH, installs VS Code extensions, and applies optional privacy tweaks.

# Usage

After installing Windows 11, complete these steps before running the bootstrap.

## Manual Steps

1. **Windows Update** `Settings → Windows Update → Advanced options → Receive updates for other Microsoft products` → **ON** Apply all updates.
    
2. **PowerShell Execution Policy** Run PowerShell as Administrator:    
        
    ```PowerShell
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
    ```

3. **Windows Terminal Settings** `Settings → System → Advanced → Terminal`
    
    - Allow local PowerShell scripts        
    - Enable Sudo        
    - Set default terminal to **Windows Terminal**
        

# Run the Bootstrap

Open an elevated PowerShell session and run:

```PowerShell
Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/Win11Bootstrap/main.ps1' | Invoke-Expression
```

This downloads the thin loader, installs prerequisites, fetches the full bootstrap bundle, and runs the main orchestrator.

# Folder Structure

```Code
Win11Bootstrap/
│   main.ps1                  # Thin loader (pre-checks, bundle download, bootstrap start)
│   WinBootstrap.ps1          # Main orchestrator (module sequencing, logging)
│   Setup-Obsidian-Hugo.ps1   # One-off helper for Obsidian + Hugo workflow
│   README.md
│
├── Config/
│       apps.json             # Winget app groups and versions
│       github.json           # Git repositories to clone
│       privacy.json          # Optional privacy settings
│       vscode-extensions.json# VS Code extensions
│
└── Modules/
        Configure-Privacy.ps1
        Configure-Shell.ps1
        Configure-Windows.ps1
        Helpers.ps1
        Install-StoreApps.ps1
        Install-VSCodeExtensions.ps1
        Install-WingetApps.ps1
        Setup-GitHub.ps1
```

# What the Bootstrap Does

## Thin Loader (`main.ps1`)

- Checks for winget    
- Downloads the full bootstrap bundle    
- Extracts it into a temp directory    
- Runs `WinBootstrap.ps1`    

## Orchestrator (`WinBootstrap.ps1`)

- Loads helper functions    
- Runs all modules in order    
- Writes a rolling log to `C:\Logs\WinBootstrap.log`    

## Module Overview

### Install-WingetApps

- Installs apps defined in `apps.json`    
- Supports groups (core, dev, ops, personal)    
- Handles dependencies and version pinning    

### Install-StoreApps

- Installs Microsoft Store apps    

### Install-VSCodeExtensions

- Installs extensions listed in `vscode-extensions.json`    

### Configure-Windows

- Applies system settings    
- Configures taskbar, Explorer, power settings, and other Windows options    

### Configure-Shell

- Sets up Windows Terminal    
- Applies shell preferences    
- Configures profile files    

### Setup-GitHub

- Creates `~/git` workspace    
- Generates SSH keypair    
- Authenticates GitHub CLI    
- Uploads SSH key if missing    
- Downloads SSH config    
- Clones repositories from `github.json`    

### Configure-Privacy

- Applies optional privacy settings from `privacy.json`    

### Helpers.ps1

- Provides shared functions:    
    - `Write-Log`        
    - module loader        
    - path refresh        
    - utility helpers