### Privacy ###

#Privacy resources On GitHub: https://github.com/TemporalAgent7/awesome-windows-privacy
#Below script is based on: https://github.com/minzi90/Win11-privacy-tool

# Enhanced Windows Privacy Settings
function Set-WindowsPrivacy {
    #Write-Log "Configuring Windows privacy settings..." -Level 'Info'
    
    # Basic Telemetry Settings
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' `
        -Name 'AllowTelemetry' -Value 0 `
        -Description "Disable Windows Telemetry"
    
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' `
        -Name 'AllowTelemetry' -Value 0 `
        -Description "Disable Telemetry Collection" 
  
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' `
        -Name 'DisableEnterpriseAuthProxy' -Value 1 `
        -Description "Disable Enterprise Authentication for Telemetry"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' `
        -Name 'DisableOneSettingsDownloads' -Value 1 `
        -Description "Disable Automatic Policy Downloads"

    # Connected User Experiences and Telemetry Service
    Set-RegistryValueWithBackup -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\DiagTrack' `
        -Name 'Start' -Value 4 `
        -Description "Disable Connected User Experiences Service"

    # Diagnostic Data Settings
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack' `
        -Name 'DiagTrackAuthorization' -Value 0 `
        -Description "Disable Diagnostic Tracking Authorization"   

    # Compatibility Telemetry
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat' `
        -Name 'DisableInventory' -Value 1 `
        -Description "Disable Application Inventory Collection"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat' `
        -Name 'DisablePCA' -Value 1 `
        -Description "Disable Program Compatibility Assistant"

    # Advertising ID and Personalization
    Set-RegistryValueWithBackup -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' `
        -Name 'Enabled' -Value 0 `
        -Description "Disable Advertising ID"

    Set-RegistryValueWithBackup -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' `
        -Name 'TailoredExperiencesWithDiagnosticDataEnabled' -Value 0 `
        -Description "Disable Tailored Experiences"

    # Cloud Content
    Set-RegistryValueWithBackup -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
        -Name 'ContentDeliveryAllowed' -Value 0 `
        -Description "Disable Content Delivery"

    Set-RegistryValueWithBackup -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
        -Name 'FeatureManagementEnabled' -Value 0 `
        -Description "Disable Feature Management"

    # Activity History and Timeline
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
        -Name 'EnableActivityFeed' -Value 0 `
        -Description "Disable Activity Feed"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
        -Name 'PublishUserActivities' -Value 0 `
        -Description "Disable Activity Publishing"
    
    # Windows Search Privacy Settings
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' `
        -Name 'ConnectedSearchUseWeb' -Value 0 `
        -Description "Disable web search results"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' `
        -Name 'DisableWebSearch' -Value 1 `
        -Description "Disable web search capability"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' `
        -Name 'AllowSearchToUseLocation' -Value 0 `
        -Description "Disable location in search"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' `
        -Name 'AllowCloudSearch' -Value 0 `
        -Description "Disable cloud search"

    Set-RegistryValueWithBackup -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings' `
        -Name 'IsDeviceSearchHistoryEnabled' -Value 0 `
        -Description "Disable search history"

    Set-RegistryValueWithBackup -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings' `
        -Name 'IsAADCloudSearchEnabled' -Value 0 `
        -Description "Disable Cloud Search in AAD"

    # Disable SafeSearch
    Set-RegistryValueWithBackup -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings' `
        -Name 'SafeSearchMode' -Value 0 `
        -Description "Disable SafeSearch"

    # Disable AutoPlay and AutoRun
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' `
        -Name 'NoDriveTypeAutoRun' -Value 255 `
        -Description "Disable AutoRun for all drives"

    # Disable Storage Sense
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense' `
        -Name 'AllowStorageSenseGlobal' -Value 0 `
        -Description "Disable Storage Sense"

    # Disable Customer Experience Improvement Program
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows' `
        -Name 'CEIPEnable' -Value 0 `
        -Description "Disable CEIP"

    # Disable Windows Feedback Experience
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' `
        -Name 'DoNotShowFeedbackNotifications' -Value 1 `
        -Description "Disable Feedback Notifications"

    # Disable Location Tracking
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Location Tracking"

    # Disable App Launch Tracking
    Set-RegistryValueWithBackup -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' `
        -Name 'Start_TrackProgs' -Value 0 `
        -Description "Disable App Launch Tracking"

    # Disable Network Location Awareness
    Set-RegistryValueWithBackup -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet' `
        -Name 'EnableActiveProbing' -Value 0 `
        -Description "Disable Network Location Awareness"
  
    # Disable Windows Tips and Suggestions
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' `
        -Name 'DisableSoftLanding' -Value 1 `
        -Description "Disable Windows Tips"

    # Disable Clipboard History and Sync
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
        -Name 'AllowClipboardHistory' -Value 0 `
        -Description "Disable Clipboard History"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
        -Name 'AllowCrossDeviceClipboard' -Value 0 `
        -Description "Disable Clipboard Sync"

    # Disable Windows Hello Face
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\FacialFeatures' `
        -Name 'EnhancedAntiSpoofing' -Value 0 `
        -Description "Disable Windows Hello Face"

    # Disable Shared Experiences
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
        -Name 'EnableCdp' -Value 0 `
        -Description "Disable Shared Experiences"

    # Disable Suggested Content in Settings App
    Set-RegistryValueWithBackup -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
        -Name 'SubscribedContent-338393Enabled' -Value 0 `
        -Description "Disable Suggested Content in Settings"    
   
     # Disable Bing Search in Start Menu
    Set-RegistryValueWithBackup -Path 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' `
        -Name 'DisableSearchBoxSuggestions' -Value 1 `
        -Description "Disable Bing Search in Start Menu"

    # Disable Windows Widget Service
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' `
        -Name 'AllowNewsAndInterests' -Value 0 `
        -Description "Disable Windows Widget Service"

    # Disable Microsoft Account Sign-in Assistant
    Set-RegistryValueWithBackup -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\wlidsvc' `
        -Name 'Start' -Value 4 `
        -Description "Disable Microsoft Account Sign-in Service"

    # Disable Windows Error Reporting
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting' `
        -Name 'Disabled' -Value 1 `
        -Description "Disable Windows Error Reporting"
 
    # Disable Device Census
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata' `
        -Name 'PreventDeviceMetadataFromNetwork' -Value 1 `
        -Description "Disable Device Metadata Collection"

    # Disable Microsoft Store Auto Install
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore' `
        -Name 'AutoDownload' -Value 2 `
        -Description "Disable Automatic Store Updates"

    # Disable Windows Welcome Experience
    Set-RegistryValueWithBackup -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
        -Name 'SubscribedContent-310093Enabled' -Value 0 `
        -Description "Disable Welcome Experience"

    # Disable Windows Spotlight
    Set-RegistryValueWithBackup -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
        -Name 'SubscribedContent-338387Enabled' -Value 0 `
        -Description "Disable Windows Spotlight"

    # Disable Inking & Typing Personalization
    Set-RegistryValueWithBackup -Path 'HKCU:\SOFTWARE\Microsoft\InputPersonalization' `
        -Name 'RestrictImplicitInkCollection' -Value 1 `
        -Description "Disable Implicit Ink Collection"
    
    Set-RegistryValueWithBackup -Path 'HKCU:\SOFTWARE\Microsoft\InputPersonalization' `
        -Name 'RestrictImplicitTextCollection' -Value 1 `
        -Description "Disable Implicit Text Collection"

    Set-RegistryValueWithBackup -Path 'HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore' `
        -Name 'HarvestContacts' -Value 0 `
        -Description "Disable Contact Harvesting"

    Set-RegistryValueWithBackup -Path 'HKCU:\SOFTWARE\Microsoft\Personalization\Settings' `
        -Name 'AcceptedPrivacyPolicy' -Value 0 `
        -Description "Disable Personalization Privacy Policy"

    # Disable language list access for websites
    Set-RegistryValueWithBackup -Path 'HKCU:\Control Panel\International\User Profile' `
        -Name 'HttpAcceptLanguageOptOut' -Value 1 `
        -Description "Disable language list access for websites"

    Set-RegistryValueWithBackup -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\LanguageConfiguration' `
        -Name 'DisableLanguageListAccess' -Value 1 `
        -Description "Disable language configuration access"
       
    # Disable suggested content in Settings app
    Set-RegistryValueWithBackup -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
        -Name 'SubscribedContent-338393Enabled' -Value 0 `
        -Description "Disable suggested content in Settings app"

    Set-RegistryValueWithBackup -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
        -Name 'SubscribedContent-353694Enabled' -Value 0 `
        -Description "Disable suggestions in Settings"

    Set-RegistryValueWithBackup -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
        -Name 'SubscribedContent-353696Enabled' -Value 0 `
        -Description "Disable additional suggestions"

    # Disable App Notifications
    Set-RegistryValueWithBackup -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications' `
        -Name 'EnableAccountNotifications' -Value 0 `
        -Description "Disable Settings App Notifications"

    # Disable Copilot
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' `
        -Name 'TurnOffWindowsCopilot' -Value 1 `
        -Description "Disable Windows Copilot"

    # Disable Lock Screen Content
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
        -Name 'DisableLogonBackgroundImage' -Value 1 `
        -Description "Disable Dynamic Lock Screen Content"

    # Disable Game DVR and Game Bar
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' `
        -Name 'AllowGameDVR' -Value 0 `
        -Description "Disable Game DVR"
        
    #Write-Log "Windows privacy settings configuration completed" -Level 'Info'        
     
}   

function Set-AppPermissions {
    #Write-Log "Configuring Windows App Permissions..." -Level 'Info'

    # App Permissions Privacy Settings
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Microphone Access by Default"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Camera Access by Default"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Account Info Access"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Contacts Access"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Calendar Access"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Phone Call Access"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Radios Access"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Bluetooth Access"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Broad File System Access"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Documents Library Access"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Pictures Library Access"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Videos Library Access"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\musicLibrary' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Music Library Access"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Email Access by Default"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Tasks Access by Default"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Messaging/Chat Access"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\downloadsFolder' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Downloads Folder Access"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureProgrammatic' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Screen Capture Access"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureWithoutBorder' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Borderless Screen Capture"

    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\screenshot' `
        -Name 'Value' -Value 'Deny' `
        -Description "Disable Screenshot Capability"   

    #Write-Log "Windows App Permissions configuration completed" -Level 'Info'        
     
}

# Windows Update Delivery Optimization Configuration
function Set-DeliveryOptimization {
    #Write-Log "Configuring Windows Update Delivery Optimization..." -Level 'Info'
    
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config' `
        -Name 'DODownloadMode' -Value 1 `
        -Description "Set Delivery Optimization to LAN Only"
    
    Set-RegistryValueWithBackup -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config' `
        -Name 'DOMaxUploadBandwidth' -Value 1 `
        -Description "Restrict Upload Bandwidth"

    #Write-Log "Windows Update Delivery Optimization configuration completed" -Level 'Info'   
       
}

Set-WindowsPrivacy
Set-AppPermissions
Set-DeliveryOptimization