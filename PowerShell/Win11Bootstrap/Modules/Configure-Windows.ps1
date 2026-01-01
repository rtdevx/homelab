<#
    Configure-Windows.ps1
    Consolidated Windows configuration:
      - System Restore
      - Power Plan
      - Daily Winget Update Task
      - Taskbar & Start Menu QoL
      - Windows Update Behavior
#>

Write-Log "Starting Windows configuration..."

# ------------------------------------------------------------
# 1. System Restore
# ------------------------------------------------------------
Write-Log "Configuring System Restore..."

try {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction Stop
    Checkpoint-Computer -Description "Initial Bootstrap Restore Point" -RestorePointType "MODIFY_SETTINGS"
    Write-Log "System Restore configured."
}
catch {
    Write-Log "Failed to configure System Restore: $($_.Exception.Message)" "WARN"
}

# ------------------------------------------------------------
# 2. Power Plan (Ultimate > High Performance > Default)
# ------------------------------------------------------------
Write-Log "Configuring Power Plan..."

try {
    $plans = powercfg -l

    $ultimate = $plans | Select-String "Ultimate performance"
    $highPerf = $plans | Select-String "High performance"

    if ($ultimate) {
        $guid = ($ultimate -split '\s+')[3]
        powercfg -setactive $guid
        Write-Log "Ultimate Performance power plan activated."
    }
    elseif ($highPerf) {
        $guid = ($highPerf -split '\s+')[3]
        powercfg -setactive $guid
        Write-Log "High Performance power plan activated."
    }
    else {
        Write-Log "No High Performance or Ultimate Performance plan available. Leaving default plan active." "INFO"
    }
}
catch {
    Write-Log "Failed to configure power plan: $($_.Exception.Message)" "WARN"
}

# ------------------------------------------------------------
# 3. Scheduled Task: Daily Winget Updater (Idle Trigger)
# ------------------------------------------------------------
Write-Log "Configuring daily winget update task..."

try {
    $taskName = "WinBootstrap-WingetUpdate"
    $taskPath = "\WinBootstrap"

    # Remove existing task if present (PowerShell + COM cleanup)
    try {
        # Try PowerShell deletion first
        $existing = Get-ScheduledTask -TaskName $taskName -TaskPath $taskPath -ErrorAction SilentlyContinue
        if ($existing) {
            Unregister-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Confirm:$false
        }

        # COM cleanup (handles ghost tasks)
        $service = New-Object -ComObject "Schedule.Service"
        $service.Connect()

        $folder = $service.GetFolder($taskPath)

        try {
            $folder.DeleteTask($taskName, 0)
        } catch {
            # Ignore if COM says it doesn't exist
        }
    }
    catch {
        Write-Log "Failed to remove existing scheduled task: $($_.Exception.Message)" "WARN"
    }

    # Create folder if missing (COM API)
    $service = New-Object -ComObject "Schedule.Service"
    $service.Connect()

    $rootFolder = $service.GetFolder("\")
    try {
        $null = $rootFolder.GetFolder($taskPath)
    } catch {
        $rootFolder.CreateFolder($taskPath) | Out-Null
    }

    # XML definition for idle-triggered daily winget update
    $taskXml = @"
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Automatically updates winget packages once per day when the system is idle.</Description>
  </RegistrationInfo>
  <Triggers>
    <IdleTrigger>
      <Repetition>
        <Interval>P1D</Interval>
      </Repetition>
      <Enabled>true</Enabled>
    </IdleTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <RunLevel>HighestAvailable</RunLevel>
      <LogonType>InteractiveToken</LogonType>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <RunOnlyIfIdle>true</RunOnlyIfIdle>
    <IdleSettings>
      <Duration>PT10M</Duration>
      <WaitTimeout>PT1H</WaitTimeout>
    </IdleSettings>
    <StartWhenAvailable>true</StartWhenAvailable>
    <AllowHardTerminate>true</AllowHardTerminate>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-NoProfile -WindowStyle Hidden -Command &quot;winget upgrade --all --silent --accept-package-agreements --accept-source-agreements&quot;</Arguments>
      <WorkingDirectory>C:\Windows\System32</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
"@

    Register-ScheduledTask -TaskName $taskName `
                           -TaskPath $taskPath `
                           -Xml $taskXml `
                           | Out-Null

    Write-Log "Winget update task configured."
}
catch {
    Write-Log "Failed to configure winget update task: $($_.Exception.Message)" "WARN"
}

# ------------------------------------------------------------
# 4. Taskbar & Start Menu Quality-of-Life
# ------------------------------------------------------------

# Disable Bing web search
Write-Log "Disabling Bing web search in Start..."
try {
    New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" `
                     -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord
    Write-Log "Bing web search disabled."
}
catch {
    Write-Log "Failed to disable Bing web search: $($_.Exception.Message)" "WARN"
}

# Disable suggested apps
Write-Log "Disabling suggested apps in Start..."
try {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
                     -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord
    Write-Log "Suggested apps disabled."
}
catch {
    Write-Log "Failed to disable suggested apps: $($_.Exception.Message)" "WARN"
}

# Taskbar search icon only
Write-Log "Setting taskbar search to icon only..."
try {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" `
                     -Name "SearchboxTaskbarMode" -Value 1 -Type DWord
    Write-Log "Taskbar search set to icon only."
}
catch {
    Write-Log "Failed to configure taskbar search: $($_.Exception.Message)" "WARN"
}

# Disable widgets
Write-Log "Disabling taskbar widgets..."
try {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
                     -Name "TaskbarDa" -Value 0 -Type DWord
    Write-Log "Taskbar widgets disabled."
}
catch {
    Write-Log "Failed to disable taskbar widgets: $($_.Exception.Message)" "WARN"
}

# Disable chat
Write-Log "Disabling taskbar chat..."
try {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
                     -Name "TaskbarMn" -Value 0 -Type DWord
    Write-Log "Taskbar chat disabled."
}
catch {
    Write-Log "Failed to disable taskbar chat: $($_.Exception.Message)" "WARN"
}

# ------------------------------------------------------------
# 5. Windows Update Behavior
# ------------------------------------------------------------

# Disable automatic reboot
Write-Log "Disabling automatic reboot after updates..."
try {
    New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" `
                     -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord
    Write-Log "Automatic reboot disabled."
}
catch {
    Write-Log "Failed to disable automatic reboot: $($_.Exception.Message)" "WARN"
}

# Notify before restart
Write-Log "Enabling notify-before-restart behavior..."
try {
    New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" `
                     -Name "SetAutoRestartNotificationDisable" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" `
                     -Name "SetAutoRestartNotificationSchedule" -Value 1 -Type DWord
    Write-Log "Notify-before-restart enabled."
}
catch {
    Write-Log "Failed to configure restart notifications: $($_.Exception.Message)" "WARN"
}

# Enable Microsoft Update
Write-Log "Enabling Microsoft Update (other Microsoft products)..."
try {
    New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" `
                     -Name "AllowMUUpdateService" -Value 1 -Type DWord
    Write-Log "Microsoft Update enabled."
}
catch {
    Write-Log "Failed to enable Microsoft Update: $($_.Exception.Message)" "WARN"
}

Write-Log "Windows configuration complete."