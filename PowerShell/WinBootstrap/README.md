
# SYNOPSIS
Windows Bootstrap - Windows 11 deployment utility.
 
# DESCRIPTION
Bootstraping Windows 11. Installing Software, uninstalling bloatware, applying privacy and security settings, setting up development environment...
MSSTORE requires user to be logged in to Microsoft in order to install software. Script should be run under your user with local Administrator rights for that reason.
    
Winget software sources can be found here: https://winget.run/

# USAGE
Run elevated powershell.

__Execute:__

```PowerShell
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/WinBootstrap/WinBootstrap.ps1'))
```

- Decryption key ($Key) must be provided in order to decrypt $Password to mount the NAS share and copy ssh keys (see "#Copy SSH keys" section).

# Components

- WinBootstrap.ps1

    Main Script.





