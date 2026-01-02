<#
    Configure-Privacy.ps1
    Config-driven strict privacy configuration:
      - Telemetry & Diagnostics
      - Advertising & Tracking
      - Content Suggestions
      - Cloud Features
      - App Permissions
      - Location Services
      - MS Store Bloatware Removal
#>

Write-Log "Starting privacy configuration..."

# ------------------------------------------------------------
# Load privacy configuration
# ------------------------------------------------------------
$privacyConfigPath = Join-Path $PSScriptRoot '..\Config\privacy.json' | Resolve-Path -ErrorAction SilentlyContinue

if (-not $privacyConfigPath) {
    Write-Log "privacy.json not found. Skipping privacy configuration." "WARN"
    return
}

try {
    $privacyConfig = Get-Content -Path $privacyConfigPath -Raw | ConvertFrom-Json -ErrorAction Stop
    Write-Log "Loaded privacy configuration from $privacyConfigPath."
}
catch {
    Write-Log "Failed to parse privacy.json: $($_.Exception.Message)" "WARN"
    return
}

# Helper: safe registry set
function Set-RegistryValue {
    param(
        [Parameter(Mandatory)]
        [string] $Path,
        [Parameter(Mandatory)]
        [string] $Name,
        [Parameter(Mandatory)]
        [Object] $Value,
        [ValidateSet("String","DWord","QWord")]
        [string] $Type = "DWord",
        [switch] $Machine
    )

    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }

        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -ErrorAction Stop
    }
    catch {
        Write-Log "Failed to set registry value ${Path}\${Name}: $($_.Exception.Message)" "WARN"
    }
}

# ------------------------------------------------------------
# 1. Telemetry & Diagnostics
# ------------------------------------------------------------
if ($privacyConfig.Telemetry) {
    Write-Log "Configuring Telemetry & Diagnostics..."

    if ($privacyConfig.Telemetry.DiagnosticLevel -eq 'Basic') {
        Set-RegistryValue -Path 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection' `
                          -Name 'AllowTelemetry' -Value 1 -Type DWord -Machine
        Write-Log "Telemetry level set to Basic."
    }

    if ($privacyConfig.Telemetry.DisableTailoredExperiences) {
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' `
                          -Name 'TailoredExperiencesWithDiagnosticDataEnabled' -Value 0 -Type DWord
        Write-Log "Tailored Experiences disabled."
    }

    if ($privacyConfig.Telemetry.DisableFeedbackPrompts) {
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\Siuf\Rules' `
                          -Name 'NumberOfSIUFInPeriod' -Value 0 -Type DWord
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\Siuf\Rules' `
                          -Name 'PeriodInNanoSeconds' -Value 0 -Type DWord
        Write-Log "Feedback prompts disabled."
    }

    if ($privacyConfig.Telemetry.DisableInkingTyping) {
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\InputPersonalization' `
                          -Name 'RestrictImplicitTextCollection' -Value 1 -Type DWord
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\InputPersonalization' `
                          -Name 'RestrictImplicitInkCollection' -Value 1 -Type DWord
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore' `
                          -Name 'HarvestContacts' -Value 0 -Type DWord
        Write-Log "Inking and typing personalization disabled."
    }
}
else {
    Write-Log "Telemetry section not present in privacy.json. Skipping." "INFO"
}

# ------------------------------------------------------------
# 2. Advertising & Tracking
# ------------------------------------------------------------
if ($privacyConfig.Advertising) {
    Write-Log "Configuring Advertising & Tracking..."

    if ($privacyConfig.Advertising.DisableAdvertisingId) {
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' `
                          -Name 'Enabled' -Value 0 -Type DWord
        Write-Log "Advertising ID disabled."
    }

    if ($privacyConfig.Advertising.DisableSettingsSuggestions) {
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
                          -Name 'SubscribedContent-338393Enabled' -Value 0 -Type DWord
        Write-Log "Settings suggestions disabled."
    }

    if ($privacyConfig.Advertising.DisableStartSuggestions) {
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
                          -Name 'SubscribedContent-338389Enabled' -Value 0 -Type DWord
        Write-Log "Start menu suggestions disabled."
    }
}
else {
    Write-Log "Advertising section not present in privacy.json. Skipping." "INFO"
}

# ------------------------------------------------------------
# 3. Content Suggestions
# ------------------------------------------------------------
if ($privacyConfig.ContentSuggestions) {
    Write-Log "Configuring Content Suggestions..."

    if ($privacyConfig.ContentSuggestions.DisableWindowsSpotlight) {
        Set-RegistryValue -Path 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent' `
                          -Name 'DisableWindowsSpotlightFeatures' -Value 1 -Type DWord
        Set-RegistryValue -Path 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent' `
                          -Name 'DisableWindowsSpotlightOnActionCenter' -Value 1 -Type DWord
        Write-Log "Windows Spotlight features disabled."
    }

    if ($privacyConfig.ContentSuggestions.DisableLockScreenFunFacts) {
        Set-RegistryValue -Path 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent' `
                          -Name 'DisableWindowsSpotlightOnLockScreen' -Value 1 -Type DWord
        Write-Log "Lock screen fun facts disabled."
    }

    if ($privacyConfig.ContentSuggestions.DisableSettingsAppSuggestions) {
        Set-RegistryValue -Path 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent' `
                          -Name 'DisableSoftLanding' -Value 1 -Type DWord
        Write-Log "Settings app suggestions disabled."
    }
}
else {
    Write-Log "ContentSuggestions section not present in privacy.json. Skipping." "INFO"
}

# ------------------------------------------------------------
# 4. Cloud Features
# ------------------------------------------------------------
if ($privacyConfig.CloudFeatures) {
    Write-Log "Configuring Cloud Features..."

    if ($privacyConfig.CloudFeatures.DisableOnlineSpeech) {
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy' `
                          -Name 'HasAccepted' -Value 0 -Type DWord
        Write-Log "Online speech recognition disabled."
    }

    if ($privacyConfig.CloudFeatures.DisableTypingPersonalization) {
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\InputPersonalization' `
                          -Name 'RestrictImplicitTextCollection' -Value 1 -Type DWord
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\InputPersonalization' `
                          -Name 'RestrictImplicitInkCollection' -Value 1 -Type DWord
        Write-Log "Typing personalization disabled."
    }

    if ($privacyConfig.CloudFeatures.DisableActivityHistory) {
        Set-RegistryValue -Path 'HKLM:\Software\Policies\Microsoft\Windows\System' `
                          -Name 'EnableActivityFeed' -Value 0 -Type DWord -Machine
        Set-RegistryValue -Path 'HKLM:\Software\Policies\Microsoft\Windows\System' `
                          -Name 'PublishUserActivities' -Value 0 -Type DWord -Machine
        Set-RegistryValue -Path 'HKLM:\Software\Policies\Microsoft\Windows\System' `
                          -Name 'UploadUserActivities' -Value 0 -Type DWord -Machine
        Write-Log "Activity history disabled."
    }

    if ($privacyConfig.CloudFeatures.DisableClipboardSync) {
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\Clipboard' `
                          -Name 'EnableCloudClipboard' -Value 0 -Type DWord
        Write-Log "Clipboard sync disabled."
    }

    if ($privacyConfig.CloudFeatures.DisableAppLaunchTracking) {
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' `
                          -Name 'Start_TrackProgs' -Value 0 -Type DWord
        Write-Log "App launch tracking disabled."
    }
}
else {
    Write-Log "CloudFeatures section not present in privacy.json. Skipping." "INFO"
}

# ------------------------------------------------------------
# 5. App Permissions
# ------------------------------------------------------------
if ($privacyConfig.AppPermissions) {
    Write-Log "Configuring App Permissions..."

    $permPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore'

    if ($privacyConfig.AppPermissions.DisableCamera) {
        Set-RegistryValue -Path "$permPath\webcam" -Name 'Value' -Value 'Deny' -Type String
        Write-Log "Camera access disabled."
    }

    if ($privacyConfig.AppPermissions.DisableMicrophone) {
        Set-RegistryValue -Path "$permPath\microphone" -Name 'Value' -Value 'Deny' -Type String
        Write-Log "Microphone access disabled."
    }

    if ($privacyConfig.AppPermissions.DisableContacts) {
        Set-RegistryValue -Path "$permPath\contacts" -Name 'Value' -Value 'Deny' -Type String
        Write-Log "Contacts access disabled."
    }

    if ($privacyConfig.AppPermissions.DisableCalendar) {
        Set-RegistryValue -Path "$permPath\appointments" -Name 'Value' -Value 'Deny' -Type String
        Write-Log "Calendar access disabled."
    }

    if ($privacyConfig.AppPermissions.DisableCallHistory) {
        Set-RegistryValue -Path "$permPath\phoneCallHistory" -Name 'Value' -Value 'Deny' -Type String
        Write-Log "Call history access disabled."
    }

    if ($privacyConfig.AppPermissions.DisableEmail) {
        Set-RegistryValue -Path "$permPath\email" -Name 'Value' -Value 'Deny' -Type String
        Write-Log "Email access disabled."
    }

    if ($privacyConfig.AppPermissions.DisableTasks) {
        Set-RegistryValue -Path "$permPath\userDataTasks" -Name 'Value' -Value 'Deny' -Type String
        Write-Log "Tasks access disabled."
    }

    if ($privacyConfig.AppPermissions.DisableMessaging) {
        Set-RegistryValue -Path "$permPath\chat" -Name 'Value' -Value 'Deny' -Type String
        Write-Log "Messaging access disabled."
    }

    if ($privacyConfig.AppPermissions.DisableRadios) {
        Set-RegistryValue -Path "$permPath\radios" -Name 'Value' -Value 'Deny' -Type String
        Write-Log "Radios access disabled."
    }

    if ($privacyConfig.AppPermissions.DisableBackgroundApps) {
        Set-RegistryValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' `
                          -Name 'GlobalUserDisabled' -Value 1 -Type DWord
        Write-Log "Background apps disabled."
    }
}
else {
    Write-Log "AppPermissions section not present in privacy.json. Skipping." "INFO"
}

# ------------------------------------------------------------
# 6. Location Services
# ------------------------------------------------------------
if ($privacyConfig.Location) {
    Write-Log "Configuring Location Services..."

    if ($privacyConfig.Location.DisableLocationServices) {
        Set-RegistryValue -Path 'HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors' `
                          -Name 'DisableLocation' -Value 1 -Type DWord -Machine
        Write-Log "Location services disabled."
    }

    if ($privacyConfig.Location.DisableLocationHistory) {
        Set-RegistryValue -Path 'HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors' `
                          -Name 'DisableLocationScripting' -Value 1 -Type DWord -Machine
        Write-Log "Location history disabled."
    }
}
else {
    Write-Log "Location section not present in privacy.json. Skipping." "INFO"
}

# ------------------------------------------------------------
# 7. MS Store Bloatware Removal
# ------------------------------------------------------------
if ($privacyConfig.Bloatware -and $privacyConfig.Bloatware.RemoveStoreApps) {
    Write-Log "Removing MS Store bloatware (config-driven)..."

    $apps = @($privacyConfig.Bloatware.Apps)

    foreach ($app in $apps) {
        try {
            $installed = Get-AppxPackage -Name $app -ErrorAction SilentlyContinue
            if ($installed) {
                Write-Log "Removing appx package: ${app}"
                Get-AppxPackage -Name $app | Remove-AppxPackage -ErrorAction SilentlyContinue
            }
            else {
                Write-Log "Appx package not installed: ${app}" "INFO"
            }
        }
        catch {
            Write-Log "Failed to process appx package ${app}: $($_.Exception.Message)" "WARN"
        }
    }
}
else {
    Write-Log "Bloatware removal disabled or not configured. Skipping." "INFO"
}

# ------------------------------------------------------------
# 8. DisableConsumerFeatures (Start Menu app suggestions)
# ------------------------------------------------------------

if ($privacyConfig.ContentSuggestions.DisableConsumerFeatures) {
    Set-RegistryValue -Path 'HKLM:\Software\Policies\Microsoft\Windows\CloudContent' `
                      -Name 'DisableConsumerFeatures' -Value 1 -Type DWord -Machine
    Write-Log "Consumer features (app suggestions) disabled."
}

Write-Log "Privacy configuration complete."
