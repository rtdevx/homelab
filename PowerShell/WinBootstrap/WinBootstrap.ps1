<#
    .SYNOPSIS
    Windows Bootstrap - Windows 11 deployment utility.
 
    .DESCRIPTION
    Bootstraping Windows 11. Installing Software, uninstalling bloatware, applying privacy and security settings, setting up development environment...
    MSSTORE requires user to be logged in to Microsoft in order to install software. Script should be run under your user with local Administrator rights for that reason.
    
    Winget software sources can be found here: https://winget.run/

    .USAGE
    Run elevated powershell.

    Execute: 

    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/WinBootstrap/WinBootstrap.ps1'))

    #Decryption key ($Key) must be provided in order to decrypt $Password to mount the NAS share and copy ssh keys (see "#Copy SSH keys" section).

#>

# Run as Administrator
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires administrator privileges. Please run as administrator." -Level 'Error'  -ForegroundColor Red
    exit 1
}

### FUNCTIONS ###
Function RefreshPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
                ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

### END FUNCTIONS ###

#Set Powershell Execution Policy and Disable UAC
Set-ExecutionPolicy Unrestricted -Force
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0

#Enable System Restore
Write-Host `n" Enabling System Restore."`n -ForegroundColor Green
Enable-ComputerRestore -Drive "C:\"

#Rename Administrator Account
$UserID = Get-LocalUser -Name 'Administrator' -ErrorAction SilentlyContinue
$NewAdmin = "Admin"

If($UserID){
Rename-LocalUser -Name "Administrator" -NewName $NewAdmin
Enable-LocalUser -Name $NewAdmin

#Change password for Local Admin
$Password = Read-Host "Enter password for "$NewAdmin": " -AsSecureString
$UserAccount = Get-LocalUser -Name $NewAdmin
$UserAccount | Set-LocalUser -Password $Password
} else { Write-Host `n" User 'Administrator' doesn't exist."`n -ForegroundColor Yellow } 

### WINGET ###

#Upgrade existing winget packages
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/WinBootstrap/Configurations/Update-WingetPackages.ps1'))

#Install New apps
Write-Output `n"Installing Apps"`n
$apps = @(
    @{name = "Microsoft.DotNet.SDK.7" }, 
    @{name = "Microsoft.DotNet.DesktopRuntime.8" },
    @{name = "Microsoft.PowerToys" },     
    @{name = "mcmilk.7zip-zstd" },
    @{name = "Rufus.Rufus" },    
    @{name = "NordSecurity.NordVPN" },
    @{name = "Notepad++.Notepad++" },  
    @{name = "DominikReichl.KeePass" },    
    @{name = "Git.Git" }, 
    @{name = "OpenJS.NodeJS.LTS" },     
    @{name = "Microsoft.VisualStudioCode" }, 
    @{name = "WinDirStat.WinDirStat" },
    @{name = "Google.Chrome" }, 
    @{name = "Mozilla.Firefox" }, 
#    @{name = "TradingView.TradingViewDesktop" },
    @{name = "QNAP.Qsync" },
    @{name = "Garmin.Express" },
    @{name = "mRemoteNG.mRemoteNG" },
    @{name = "Lenovo.SystemUpdate" },
    @{name = "Obsidian.Obsidian" },
    # Starthip Cross-Shell Prompt for Windows Terminal (https://starship.rs/)
    @{name = "Starship.Starship" }    
);

#More packages: https://winget.run/

Foreach ($app in $apps) {
    $listApp = winget list --exact -q $app.name
    If (![String]::Join("", $listApp).Contains($app.name)) {
        Write-host "Installing:" $app.name -ForegroundColor Green
        
            winget install --exact --silent --accept-source-agreements --accept-package-agreements --scope machine --id $app.name 
    
        } else { Write-host "Skipping Install of " $app.name -ForegroundColor Yellow }    
}

#Some apps don't support -- scope machine
Write-Output `n"Trading View (default scope)."`n
winget install -e --id TradingView.TradingViewDesktop
Write-Output `n"Discord (default scope)."`n
winget install -e --id Discord.Discord

#Refresh Environment Variables after installing software
RefreshPath

#Create Scheduled Task to update packages every time computer locks
Write-Host `n" Creating Scheduled Task to update packages on computer lock."`n -ForegroundColor Green

$TaskName = "Update Packages"
$TaskFolder = "\Custom"
$ScriptUrl = "https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/WinBootstrap/Configurations/Update-WingetPackages.ps1"

# Ensure Custom folder exists
$taskService = New-Object -ComObject Schedule.Service
$taskService.Connect()
$rootFolder = $taskService.GetFolder("\")
try {
    $null = $rootFolder.GetFolder($TaskFolder)
} catch {
    $rootFolder.CreateFolder($TaskFolder)
}

# Define the action
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptUrl`""

# Define the trigger (on workstation lock)
$trigger = New-ScheduledTaskTrigger -AtLogOn
$trigger.Enabled = $true
$trigger.Id = "OnLock"
$trigger.Delay = (New-TimeSpan -Seconds 1)

# Register the Scheduled Task
#Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskFolder -Action $action -Trigger $trigger -User "NT AUTHORITY\SYSTEM" -RunLevel Highest
Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskFolder -Action $action -Trigger $trigger -User "$env:USERNAME" -RunLevel Highest

Write-Host "Scheduled Task '$TaskName' created in folder '$TaskFolder', executing script from '$ScriptUrl'."

### CUSTOMIZATIONS ###

#Install additional VSCode Extensions

<#
--install-extension <ext-id | path> Installs or updates an extension. The
                                      argument is either an extension id or a
                                      path to a VSIX. The identifier of an
                                      extension is '${publisher}.${name}'. Use
                                      '--force' argument to update to latest
                                      version. To install a specific version
                                      provide '@${version}'. For example:
                                      'vscode.csharp@1.2.3'.
#>

Write-Host `n"Installing VSCode extensions."`n -ForegroundColor Green
start-process code -windowstyle Hidden -ArgumentList "--install-extension ms-vscode.powershell --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension ms-vscode-remote.remote-ssh --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension ms-vscode.remote-server --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension ms-vscode-remote.remote-wsl --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension ms-vscode-remote.vscode-remote-extensionpack --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension redhat.vscode-yaml --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension github.copilot --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension github.copilot-chat --force" -PassThru -Wait

#Set Windows to show known file extensions
Write-Host `n"Setting Windows to show file extensions." -ForegroundColor Green
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -PropertyType DWORD -Force

#Set Search Taskbar to icon only
Write-Host `n"Setting Search Taskbar to icon only."`n -ForegroundColor Green
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchBoxTaskbarMode -Value 1 -Type DWord -Force

#Enable Sudo in Windows Terminal
Write-Host `n"Enabling sudo."`n -ForegroundColor Green
sudo config --enable normal

#Change Power Plans (source: https://www.makeuseof.com/restore-missing-default-power-plans-windows-11/)
Write-Host `n"Setting up Power Plan."`n -ForegroundColor Green
powercfg /setactive SCHEME_MIN
#powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
Write-Host `n"Power Plan set to:"`n -ForegroundColor Green
powercfg /L

#Configure Git

if ($null -eq $Key) {
    Write-Host `n"The variable 'Key' does not exist or has no value assigned. Skipping Git Configuration"`n -ForegroundColor Yellow
} else {

Write-Host `n"Configuring Git."`n -ForegroundColor Green
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/WinBootstrap/Configurations/Configure-Git.ps1'))

}

#Configure Windows Terminal
Write-Host `n"Configuring Windows Terminal."`n -ForegroundColor Green
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/WinBootstrap/Configurations/Configure-WindowsTerminal.ps1'))

#Configure Privacy Settings
Write-Host `n"Applying Privacy..."`n -ForegroundColor Green
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/WinBootstrap/Configurations/Configure-Privacy.ps1'))

#Enable WSL
Write-Host `n"Installing Ubuntu WSL."`n -ForegroundColor Green
wsl --install ; wsl --status ; wsl --update