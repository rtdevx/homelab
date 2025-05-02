
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

#Winget

#Installing Pre-requisites
Get-WindowsCapability -Online -Name NetFx3

#Upgrading existing winget packages
winget source update ; winget upgrade --all --accept-package-agreements --accept-source-agreements --silent

#Install New apps
Write-Output "Installing Apps"
$apps = @(
    @{name = "mcmilk.7zip-zstd" }, 
    @{name = "NordVPN.NordVPN" },
    @{name = "Notepad++.Notepad++" },  
    @{name = "Git.Git" }, 
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

Foreach ($app in $apps) {
    $listApp = winget list --exact -q $app.name
    if (![String]::Join("", $listApp).Contains($app.name)) {
        Write-host "Installing:" $app.name
        
            winget install --exact --silent --accept-source-agreements --accept-package-agreements --scope allusers $app.name 
    
        }
    
    else {

        Write-host "Skipping Install of " $app.name

    }    
}




