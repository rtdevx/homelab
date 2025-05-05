# SYNOPSIS
Windows Bootstrap - Windows 11 deployment utility.
 
# DESCRIPTION
Bootstraping Windows 11. Installing Software, uninstalling bloatware, applying privacy and security settings, setting up development environment...
MSSTORE requires user to be logged in to Microsoft in order to install software. Script should be run under your user with local Administrator rights for that reason.
    
*Winget software sources can be found here:* https://winget.run/

# USAGE
Run elevated powershell.

**Execute:**

```PowerShell
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/WinBootstrap/WinBootstrap.ps1'))
```

_Decryption key ($Key) must be provided in order to decrypt $Password to mount the NAS share and copy ssh keys. **If $Key variable is not present, Git configuration will be skipped.**_

# Components

#### WinBootstrap

- Enable System Restore
- Rename Administrator Account
- Change password for Local Admin
- Enable Automatic Registry Backup
- Upgrade existing winget packages (Invoke-Expression)
- Install New apps
- Install additional VSCode Extensions
- Set Windows to show known file extensions
- Set Search Taskbar to icon only
- Enable WSL
- Enable Sudo in Windows Terminal
- Change Power Plans (*source:* https://www.makeuseof.com/restore-missing-default-power-plans-windows-11/)
- Configure Git (Invoke-Expression)
- Configure Windows Terminal (Invoke-Expression)
- Configure Privacy Settings (Invoke-Expression)

## Configurations

#### Configure-Git

**The variable '$Key' is required to decrypt credentials on the NAS system where my .ssh keys are stored. If '$Key' is not present, Git will not be configured.**

- Git config
- Copy SSH keys
- Create Git folder for all users under *C:\Users\$User\Git*
- Secure SSH keys
- Clone Public repositories

#### Configure-Privacy

> Privacy resources On GitHub:
>
>> https://github.com/TemporalAgent7/awesome-windows-privacy
>> https://github.com/TheWorldOfPC/Windows11-Debloat-Privacy-Guide

- Remove Bloatware from MSSTORE
- Remove Cortana
- Remove Music,TV
- Remove M$ Solitaire collection
- Remove Help and Feedback Hub
- Remove Maps
- Remove Weather, News
- Remove Sound Recorder
- Remove Quick Assist
- Remove XBOX
- Turn Off Windows Error Reporting
- Removing Telemetry and other unnecessary services
- Disabling Privacy-Related Scheduled Tasks

#### Configure-WindowsTerminal

**Setting up Windows Terminal with Starship Cross-Shell Prompt** (*source:* https://starship.rs/)

- Install Nerd Fonts (*source:* https://www.nerdfonts.com/) (Invoke-Expression)
- Install Starhip Cross-Shell Prompt to start with Windows Terminal
- Add shell icons (*source:* https://www.hanselman.com/blog/my-ultimate-powershell-prompt-with-oh-my-posh-and-the-windows-terminal)
- Enable IntelliSense (*source:* https://learn.microsoft.com/en-us/powershell/module/psreadline/about/about_psreadline)
- Apply Starship Configuration
- Apply Windows Terminal Settings

> More Windows Terminal Themes: https://windowsterminalthemes.dev/