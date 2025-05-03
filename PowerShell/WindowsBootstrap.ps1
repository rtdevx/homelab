
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

    iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/WindowsBootstrap.ps1'))

    #Decryption key ($Key) must be provided in order to decrypt $Password to mount the NAS share and copy ssh keys (see "#Copy SSH keys" section).

#>

# Run as Administrator
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires administrator privileges. Please run as administrator." -Level 'Error'  -ForegroundColor Red
    exit 1
}

#Set Powershell Execution Policy and Disable UAC
Set-ExecutionPolicy Unrestricted -Force
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0

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

#Remove msstore Apps
Write-Output "Removing Bloatware from MSSTORE"

$apps = "Microsoft.549981C3F5F10", "Microsoft.3DBuilder", "Microsoft.Appconnector", "Microsoft.BingFinance", "Microsoft.BingNews",
 "Microsoft.BingSports", "Microsoft.BingTranslator", "Microsoft.GamingServices", "Microsoft.Microsoft3DViewer", 
 "Microsoft.MicrosoftOfficeHub", "Microsoft.MicrosoftSolitaireCollection", "Microsoft.MinecraftUWP", "Microsoft.People", 
 "Microsoft.Print3D", "Microsoft.SkypeApp", "Microsoft.Wallet", "Microsoft.WindowsAlarms", "Microsoft.WindowsCamera", 
 "microsoft.windowscommunicationsapps", "Microsoft.WindowsMaps", "Microsoft.WindowsPhone", "Microsoft.WindowsSoundRecorder", 
 "Microsoft.Xbox.TCUI", "Microsoft.XboxApp", "Microsoft.XboxGameOverlay", "Microsoft.XboxGamingOverlay", "Microsoft.XboxSpeechToTextOverlay", 
 "Microsoft.YourPhone", "Microsoft.ZuneMusic", "Microsoft.ZuneVideo", "Microsoft.CommsPhone", "Microsoft.ConnectivityStore", 
 "Microsoft.GetHelp", "Microsoft.Getstarted", "Microsoft.Messaging", "Microsoft.Office.Sway", "Microsoft.OneConnect", 
 "Microsoft.WindowsFeedbackHub", "Microsoft.Microsoft3DViewer", "Microsoft.BingFoodAndDrink", "Microsoft.BingHealthAndFitness", 
 "Microsoft.BingTravel", "Microsoft.WindowsReadingList", "Microsoft.MixedReality.Portal", "Microsoft.ScreenSketch", "Microsoft.XboxGamingOverlay", 
 "Microsoft.YourPhone", "2FE3CB00.PicsArt-PhotoStudio", "46928bounde.EclipseManager", "613EBCEA.PolarrPhotoEditorAcademicEdition", 
 "6Wunderkinder.Wunderlist", "7EE7776C.LinkedInforWindows", "89006A2E.AutodeskSketchBook", "A278AB0D.DisneyMagicKingdoms", 
 "A278AB0D.MarchofEmpires", "ActiproSoftwareLLC.562882FEEB491", "CAF9E577.Plex", "ClearChannelRadioDigital.iHeartRadio", 
 "D52A8D61.FarmVille2CountryEscape", "D5EA27B7.Duolingo-LearnLanguagesforFree", "DB6EA5DB.CyberLinkMediaSuiteEssentials", 
 "DolbyLaboratories.DolbyAccess", "DolbyLaboratories.DolbyAccess", "Drawboard.DrawboardPDF", "Facebook.Facebook", 
 "Fitbit.FitbitCoach", "Flipboard.Flipboard", "GAMELOFTSA.Asphalt8Airborne", "KeeperSecurityInc.Keeper", "NORDCURRENT.COOKINGFEVER",
  "PandoraMediaInc.29680B314EFC2", "Playtika.CaesarsSlotsFreeCasino", "ShazamEntertainmentLtd.Shazam", "SlingTVLLC.SlingTV", 
  "TheNewYorkTimes.NYTCrossword", "ThumbmunkeysLtd.PhototasticCollage", "TuneIn.TuneInRadio", "WinZipComputing.WinZipUniversal", 
  "XINGAG.XING", "flaregamesGmbH.RoyalRevolt2", "king.com.*", "king.com.BubbleWitch3Saga", "king.com.CandyCrushSaga", "king.com.CandyCrushSodaSaga", "Microsoft.Advertising.Xaml",
  "9E2F88E3.Twitter", "4DF9E0F8.Netflix", "Microsoft.NetworkSpeedTest"

#"Microsoft.WindowsStore","Microsoft.BingWeather", "Microsoft.FreshPaint", "Microsoft.MicrosoftPowerBIForWindows", "Microsoft.MicrosoftStickyNotes","Microsoft.Office.OneNote", "Microsoft.Windows.Photos", "Microsoft.WindowsCalculator", "Microsoft.MSPaint", "SpotifyAB.SpotifyMusic"
Foreach ($app in $apps)
{
  Write-host "Uninstalling:" $app
  Get-AppxPackage -allusers $app | Remove-AppxPackage
}

#Enable Automatic Registry Backup
<#
Among other things, this runs the RegIdleBackup task. 
The task copies the system registry files (DEFAULT, SAM, SECURITY, SOFTWARE, and SYSTEM) from the %windir%\System32\config to the %windir%\System32\config\RegBack folder.
Source: https://woshub.com/enable-auto-registry-backup-windows/
#>

#New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Configuration Manager" -Name EnablePeriodicBackup -Type DWORD -Value 1

If ((Get-ItemPropertyValue -path "HKLM:\System\CurrentControlSet\Control\Session Manager\Configuration Manager" -Name EnablePeriodicBackup) -eq "1") {
    
    Write-Host `n" Registry Periodic backup is already enabled. Skipping."`n -ForegroundColor Green

    } else { Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Configuration Manager" -Name EnablePeriodicBackup -Type DWORD -Value 1 ;

    Write-Host `n"Registry Periodic backup ENABLED."`n -ForegroundColor Green

           }

### WINGET ###

#Upgrading existing winget packages
winget source update ; winget upgrade --all --accept-package-agreements --accept-source-agreements --silent

#Install New apps
Write-Output `n"Installing Apps"`n
$apps = @(
    @{name = "Microsoft.DotNet.SDK.7" }, 
    @{name = "Microsoft.DotNet.DesktopRuntime.8" },
    @{name = "Microsoft.PowerToys" },     
    @{name = "mcmilk.7zip-zstd" }, 
    @{name = "NordSecurity.NordVPN" },
    @{name = "Notepad++.Notepad++" },  
    @{name = "Git.Git" }, 
    @{name = "OpenJS.NodeJS.LTS" },     
    @{name = "Microsoft.VisualStudioCode" }, 
    @{name = "WinDirStat.WinDirStat" },
    @{name = "Google.Chrome" }, 
    @{name = "Mozilla.Firefox" }, 
    @{name = "TradingView.TradingViewDesktop" },
    @{name = "QNAP.Qsync" },
    @{name = "Garmin.Express" },
    @{name = "Garmin.BaseCamp" },
    @{name = "mRemoteNG.mRemoteNG" },
    @{name = "Lenovo.SystemUpdate" },
    @{name = "Obsidian.Obsidian" }
);

#More packages: https://winget.run/

Foreach ($app in $apps) {
    $listApp = winget list --exact -q $app.name
    If (![String]::Join("", $listApp).Contains($app.name)) {
        Write-host "Installing:" $app.name -ForegroundColor Green
        
            winget install --exact --silent --accept-source-agreements --accept-package-agreements --scope machine --id $app.name 
    
        } else { Write-host "Skipping Install of " $app.name -ForegroundColor Yellow }    
}

### CUSTOMIZATIONS ###

#Set Windows to show file extensions
Write-Host `n"Setting Windows to show file extensions." -ForegroundColor Green
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -PropertyType DWORD -Force

#Set Search Taskbar to icon only
Write-Host `n"Setting Search Taskbar to icon only."`n -ForegroundColor Green
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchBoxTaskbarMode -Value 1 -Type DWord -Force

#Enable WSL
Write-Host `n"Installing Ubuntu WSL."`n -ForegroundColor Green
wsl --install ; wsl --status

#Enable Sudo
Write-Host `n"Enabling sudo."`n -ForegroundColor Green
sudo config --enable normal

#Power Plans (source: https://www.makeuseof.com/restore-missing-default-power-plans-windows-11/)
Write-Host `n"Setting up Power Plan."`n -ForegroundColor Green

powercfg /setactive SCHEME_MIN
#powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

Write-Host `n"Power Plan set to:"`n -ForegroundColor Green
powercfg /L

### Git ###

Write-Host `n"Setting up Git."`n -ForegroundColor Green

#Git config
git config --global user.name "$env:UserName"
git config --global user.email "$env:UserName@localhost"

#Copy SSH keys
Write-Host `n"Copying SSH Keys for $env:UserName."`n -ForegroundColor Green
$CurrentGitUser = $env:UserName
$SSHLocalFolder = "C:\Users\$CurrentGitUser\.ssh"

If(!(test-path -PathType container $SSHLocalFolder)) {
    New-Item -ItemType Directory -Path $SSHLocalFolder      
}

#Create Git folder for all users
$Users = (Get-ChildItem C:\Users).Name

ForEach($User in $Users) {

    New-Item -Path "C:\Users\$User\" -Name "Git" -ItemType "directory" -ErrorAction SilentlyContinue
    
}

If(!(Test-Path -PathType container $SSHLocalFolder)) {

$Encrypted = "76492d1116743f0423413b16050a5345MgB8AE8AcQBCADAARgBmAEQAbgBrAEMAaAA3AE4AdwBPAEMAQQBFADQATAB0AEEAPQA9AHwANAAxADYANgA3AGIANwBmADMAZAA1ADMAZgBmADcAYQBiAGEAYQA1AGYAZQBkADkANwAwADUAMgA5ADgAYgBjADUAOQAwADgAYgAxADgAYQA1ADUANABhAGIAYQAyADEAZQAxADIANQBkAGUAMAAxADIAYgAzADAAYgBlAGYAZgA3AGEAMwAyAGEAZQAwAGMANQBmADUANgBmADEAYwA0AGYAMwAxADEAMAA4AGQAMwAyAGEAMwBmADcANgAwADEA"
#Decryption key ($Key) must be included in the script that is calling this script.
$Password = ConvertTo-SecureString $Encrypted -Key $Key

$Credential = New-Object System.Management.Automation.PsCredential("_svcScript", $Password)

New-PSDrive -name "X" -PSProvider FileSystem -Root \\xfiles\Automation -Persist -Credential $Credential

Copy-Item -Path X:\Ansible\Keys\Windows\.ssh\* -Destination $SSHLocalFolder -Recurse

Remove-PSDrive -name "X" -Force

#Secure SSH keys

    Get-Item $SSHLocalFolder -Force | ForEach-Object { $_.Attributes = $_.Attributes -bor "Hidden" }
    Get-Item $SSHLocalFolder -Force | ForEach-Object { $_.Attributes = $_.Attributes -bor "ReadOnly" }
    Get-Item $SSHLocalFolder\* -Force | ForEach-Object { $_.Attributes = $_.Attributes -bor "ReadOnly" }

<#
    #Set Key File Variable:
    New-Variable -Name PKFile -Value "$SSHLocalFolder\id_rsa_git"

    #Remove Inheritance:
    Icacls $PKFile /c /t /Inheritance:d

    #Set Ownership to Owner:
    #Key's within $env:UserProfile:
    Icacls $PKFile /c /t /Grant ${env:UserName}:F

    #Key's outside of $env:UserProfile:
    TakeOwn /F $PKFile
    Icacls $PKFile /c /t /Grant:r ${env:UserName}:F

    #Remove All Users, except for Owner:
    Icacls $PKFile /c /t /Remove:g Administrator "Authenticated Users" BUILTIN\Administrators BUILTIN Everyone System Users

    #Verify:
    Icacls $PKFile

    #Remove Variable:
    Remove-Variable -Name PKFile
#>

} else { Write-Host ".ssh folder already exist. Skipping" -ForegroundColor Yellow }

#Clone Public repositories

If(!(test-path -PathType container C:\Users\$User\Git\Public)) {

    New-Item -ItemType Directory -Path C:\Users\$User\Git\Public

} 

$ErrorActionPreference = "SilentlyContinue"

#Public Repositories
Set-Location -Path C:\Users\$User\Git\Public

git clone git@github.com:rtdevx/homelab.git

git clone git@github.com:rtdevx/rtdevx.github.io.git

$ErrorActionPreference = "Continue"

### Set up Terminal ###

Write-Host `n"Setting up Windows Terminal..."`n -ForegroundColor Green

# Installing fonts (source: https://www.nerdfonts.com/)

$WorkDir = "C:\TEMP"

If(!(test-path -PathType container $WorkDir)) {

    New-Item -ItemType Directory -Path $WorkDir

} 

Write-Host `n"Downloading fonts..."`n -ForegroundColor Yellow
Invoke-WebRequest https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip -Outfile C:\TEMP\FiraCode.zip

Expand-Archive -Path "$WorkDir\FiraCode.zip" -DestinationPath "$WorkDir\FiraCode"

Write-Host `n"Installing fonts..."`n -ForegroundColor Green

# Set font source location

$FontFolder = "$WorkDir\FiraCode"

# Get a list of font files

$FontFiles = Get-ChildItem -Path $FontFolder -Filter *.ttf

#Import the Microsoft.PowerShell.Utility module

Import-Module -Name Microsoft.PowerShell.Utility

# Install the fonts

ForEach ($FontFile in $FontFiles) {

    #If (-not(Test-Path "C:\Windows\Fonts\$FontFile.FullName")) {    

        #Add-Font -Path $FontFile.FullName
        Write-Host "$FontFile.FullName"

    #} else { Write-Host "$FontFile.FullName already exists. Skipping..." -ForegroundColor Yellow }

}

Remove-Item $WorkDir -Force -Recurse

<#

$Font = "FiraCodeNerdFontPropo-Retina.ttf"

If (-not(Test-Path "C:\Windows\Fonts\$Font")) {

Copy-Item $WorkDir\FiraCode\$Font C:\Windows\fonts\

} else { Write-Host "$Font is already installed... Skipping." -ForegroundColor Yellow }

Remove-Item $WorkDir -Force

#>

<#
Set-Location -Path C:\TEMP\FiraCode

$Fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
Foreach ($File in gci *.ttf)
{
    $FileName = $File.Name
    if (-not(Test-Path -Path "C:\Windows\fonts\$fileName" )) {
        Write-Host $FileName
        dir $File | %{ $Fonts.CopyHere($_.fullname) }
    }
}
Copy-Item *.ttf c:\windows\fonts\

#>

### Privacy ###

Write-Host `n"Applying Privacy..."`n -ForegroundColor Green