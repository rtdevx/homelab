
<#
    .SYNOPSIS
    Windows Bootstrap - Windows 11 deployment utility.
 
    .DESCRIPTION
    Bootstraping Windows 11. Installing Software, uninstalling bloatware, applying privacy and security settings, setting up development environment...
    MSSTORE requires user to be logged in to Microsoft in order to install software. Script should be run under your user with local Administrator rights for that reason.
    
    .USAGE
    Run elevated powershell.
    Execute: 

    iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/rtdevx/homelab/refs/heads/main/PowerShell/WindowsBootstrap.ps1'))

#>

#Set Powershell Execution Policy and Disable UAC
Set-ExecutionPolicy Unrestricted -Force
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0

#Rename Administrator Account
$UserID = Get-LocalUser -Name 'Administrator' -ErrorAction SilentlyContinue
$NewAdmin = "Admin"

if($UserID){
Rename-LocalUser -Name "Administrator" -NewName $NewAdmin
Enable-LocalUser -Name $NewAdmin

#Change password for Local Admin
$Password = Read-Host "Enter password for "$NewAdmin": " -AsSecureString
$UserAccount = Get-LocalUser -Name $NewAdmin
$UserAccount | Set-LocalUser -Password $Password
} 
else {

    Write-Host "User $UserID doesn't exist."

} 

#Remove msstore Apps
Write-Output "Removing Bloatware from MSSTORE"

$apps = "Microsoft.549981C3F5F10", "Microsoft.3DBuilder", "Microsoft.Appconnector", "Microsoft.BingFinance", "Microsoft.BingNews", "Microsoft.BingSports", "Microsoft.BingTranslator", "Microsoft.GamingServices", "Microsoft.Microsoft3DViewer", "Microsoft.MicrosoftOfficeHub", "Microsoft.MicrosoftSolitaireCollection", "Microsoft.MinecraftUWP", "Microsoft.People", "Microsoft.Print3D", "Microsoft.SkypeApp", "Microsoft.Wallet", "Microsoft.WindowsAlarms", "Microsoft.WindowsCamera", "microsoft.windowscommunicationsapps", "Microsoft.WindowsMaps", "Microsoft.WindowsPhone", "Microsoft.WindowsSoundRecorder", "Microsoft.Xbox.TCUI", "Microsoft.XboxApp", "Microsoft.XboxGameOverlay", "Microsoft.XboxGamingOverlay", "Microsoft.XboxSpeechToTextOverlay", "Microsoft.YourPhone", "Microsoft.ZuneMusic", "Microsoft.ZuneVideo", "Microsoft.CommsPhone", "Microsoft.ConnectivityStore", "Microsoft.GetHelp", "Microsoft.Getstarted", "Microsoft.Messaging", "Microsoft.Office.Sway", "Microsoft.OneConnect", "Microsoft.WindowsFeedbackHub", "Microsoft.Microsoft3DViewer", "Microsoft.BingFoodAndDrink", "Microsoft.BingHealthAndFitness", "Microsoft.BingTravel", "Microsoft.WindowsReadingList", "Microsoft.MixedReality.Portal", "Microsoft.ScreenSketch", "Microsoft.XboxGamingOverlay", "Microsoft.YourPhone", "2FE3CB00.PicsArt-PhotoStudio", "46928bounde.EclipseManager", "613EBCEA.PolarrPhotoEditorAcademicEdition", "6Wunderkinder.Wunderlist", "7EE7776C.LinkedInforWindows", "89006A2E.AutodeskSketchBook", "A278AB0D.DisneyMagicKingdoms", "A278AB0D.MarchofEmpires", "ActiproSoftwareLLC.562882FEEB491", "CAF9E577.Plex", "ClearChannelRadioDigital.iHeartRadio", "D52A8D61.FarmVille2CountryEscape", "D5EA27B7.Duolingo-LearnLanguagesforFree", "DB6EA5DB.CyberLinkMediaSuiteEssentials", "DolbyLaboratories.DolbyAccess", "DolbyLaboratories.DolbyAccess", "Drawboard.DrawboardPDF", "Facebook.Facebook", "Fitbit.FitbitCoach", "Flipboard.Flipboard", "GAMELOFTSA.Asphalt8Airborne", "KeeperSecurityInc.Keeper", "NORDCURRENT.COOKINGFEVER", "PandoraMediaInc.29680B314EFC2", "Playtika.CaesarsSlotsFreeCasino", "ShazamEntertainmentLtd.Shazam", "SlingTVLLC.SlingTV", "TheNewYorkTimes.NYTCrossword", "ThumbmunkeysLtd.PhototasticCollage", "TuneIn.TuneInRadio", "WinZipComputing.WinZipUniversal", "XINGAG.XING", "flaregamesGmbH.RoyalRevolt2", "king.com.*", "king.com.BubbleWitch3Saga", "king.com.CandyCrushSaga", 
"king.com.CandyCrushSodaSaga", "Microsoft.Advertising.Xaml"

#"Microsoft.WindowsStore","Microsoft.BingWeather", "Microsoft.FreshPaint", "Microsoft.MicrosoftPowerBIForWindows", "Microsoft.MicrosoftStickyNotes", "Microsoft.NetworkSpeedTest","Microsoft.Office.OneNote", "Microsoft.Windows.Photos", "Microsoft.WindowsCalculator", "Microsoft.MSPaint", "9E2F88E3.Twitter", "4DF9E0F8.Netflix", "SpotifyAB.SpotifyMusic"
Foreach ($app in $apps)
{
  Write-host "Uninstalling:" $app
  Get-AppxPackage -allusers $app | Remove-AppxPackage
}

<#
#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#Install New apps
$ChocoInstalled = $false
if (Get-Command choco.exe -ErrorAction SilentlyContinue) {
    $ChocoInstalled = $true
}

$Packages = '7zip', 'notepadplusplus', 'git', 'vscode', 'nodejs', 'mremoteng', 'keepass', 'googlechrome', 'firefox'

ForEach ($PackageName in $Packages)
{
    choco install $PackageName -y
}
#>

#Winget

#Upgrading existing winget packages
winget source update ; winget upgrade --all --accept-package-agreements --accept-source-agreements --accept-unknown --silent

#Install packages with winget

<#
winget install -e --id mcmilk.7zip-zstd --silent && `
winget install -e --id NordVPN.NordVPN --silent && `
winget install -e --id Notepad++.Notepad++ --silent && `
winget install -e --id Git.Git --silent && `
winget install -e --id Microsoft.VisualStudioCode --silent && `
winget install -e --id DominikReichl.KeePass --silent && `
winget install -e --id WinDirStat.WinDirStat --silent && `
winget install -e --id Google.Chrome --silent && `
winget install -e --id Mozilla.Firefox --silent && `
winget install -e --id TradingView.TradingViewDesktop --silent && `
winget install -e --id QNAP.Qsync --silent && `
winget install -e --id Garmin.Express --silent && `
winget install -e --id Garmin.BaseCamp --silent && `
winget install -e --id mRemoteNG.mRemoteNG --silent && `
winget install -e --id Lenovo.SystemUpdate --silent && `
winget install -e --id Obsidian.Obsidian --silent && `
#>

winget install -e --id mcmilk.7zip-zstd --silent && `
                    NordVPN.NordVPN --silent && `
                    Notepad++.Notepad++ --silent && `
                    Git.Git --silent && `
                    Microsoft.VisualStudioCode --silent && `
                    DominikReichl.KeePass --silent && `
                    WinDirStat.WinDirStat --silent && `
                    Google.Chrome --silent && `
                    Mozilla.Firefox --silent && `
                    TradingView.TradingViewDesktop --silent && `
                    QNAP.Qsync --silent && `
                    Garmin.Express --silent && `
                    Garmin.BaseCamp --silent && `
                    mRemoteNG.mRemoteNG --silent && `
                    Lenovo.SystemUpdate --silent && `
                    Obsidian.Obsidian --silent







