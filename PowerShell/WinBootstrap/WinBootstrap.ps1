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

#Create logs folder
$LogsFolder = "C:\Logs"

If(!(Test-Path -PathType container $LogsFolder)) {
    New-Item -ItemType Directory -Path $LogsFolder      
}

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
    @{name = "GnuPG.Gpg4win" },    
    #@{name = "NordSecurity.NordVPN" },
    @{name = "ProtonTechnologies.ProtonVPN" },    
    @{name = "Cloudflare.cloudflared" },    
    @{name = "Cloudflare.Warp" },  
    @{name = "Amazon.AWSCLI" }, 
    @{name = "Hashicorp.Terraform" },    
    @{name = "Notepad++.Notepad++" },
    @{name = "hello-efficiency-inc.raven-reader" },       
    @{name = "DominikReichl.KeePass" },    
    @{name = "Git.Git" }, 
    @{name = "OpenJS.NodeJS.LTS" },     
    @{name = "Microsoft.VisualStudioCode" }, 
    @{name = "WinDirStat.WinDirStat" },
    @{name = "Google.Chrome" }, 
    @{name = "Mozilla.Firefox" }, 
    @{name = "QNAP.Qsync" },
    @{name = "Garmin.Express" },
    @{name = "mRemoteNG.mRemoteNG" },
    @{name = "Lenovo.SystemUpdate" },
    @{name = "Obsidian.Obsidian" },
    @{name = "Hugo.Hugo.Extended" },    
    @{name = "Zoom.Zoom" },    
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
Write-Output `n"Installing Trading View (default scope)."`n
winget install -e --id TradingView.TradingViewDesktop
#Write-Output `n"Discord (default scope)."`n
#winget install -e --id Discord.Discord

#Refresh Environment Variables after installing software
RefreshPath

#Create Scheduled Task to update packages every time computer locks
$TaskName = "UpdateWingetPackages"
$TaskFolder = "\Custom"
$ScriptUrl = "https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/WinBootstrap/Configurations/Update-WingetPackages.ps1"
$ScriptPath = "$env:TEMP\UpdateWingetPackages`.ps1"

# Ensure Custom folder exists
$taskService = New-Object -ComObject Schedule.Service
$taskService.Connect()
$rootFolder = $taskService.GetFolder("\")
try {
    $null = $rootFolder.GetFolder($TaskFolder)
} catch {
    $rootFolder.CreateFolder($TaskFolder)
}

# Download script from GitHub
Invoke-WebRequest -Uri $ScriptUrl -OutFile $ScriptPath

# Create the Scheduled Task using schtasks
schtasks /Create /TN "$TaskFolder\$TaskName" /F /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File $ScriptPath" `
/SC ONEVENT /EC System /MO *[System/EventID=44] /RU "SYSTEM"
#/SC ONIDLE /RU "SYSTEM" /I 1

Write-Host "Scheduled Task '$TaskName' created in folder '$TaskFolder', executing script from '$ScriptPath'."

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
start-process code -windowstyle Hidden -ArgumentList "--install-extension johnpapa.vscode-peacock --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension ms-azuretools.vscode-docker --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension esbenp.prettier-vscode --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension eamodio.gitlens --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension formulahendry.code-runner --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension ms-vsliveshare.vsliveshare --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension pkief.material-icon-theme --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension tomoki1207.pdf --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension mechatroner.rainbow-csv --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension aaron-bond.better-comments --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension hnw.vscode-auto-open-markdown-preview --force" -PassThru -Wait
start-process code -windowstyle Hidden -ArgumentList "--install-extension HashiCorp.terraform --force" -PassThru -Wait

# todo: https://raw.githubusercontent.com/rtdevx/dotfiles/refs/heads/main/vscode/settings.json can be copied to C:\Users\robk\AppData\Roaming\Code\User\settings.json in order to make Better Comments work out of the box. Should be applied automatically on a schedule or during update.

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
