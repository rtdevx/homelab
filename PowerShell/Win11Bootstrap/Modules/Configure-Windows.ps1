<#
    Configure-Windows.ps1
    Consolidated Windows configuration:
      - System Restore
      - Power Plan
#>

Write-Log "Starting Windows configuration..."

# ------------------------------------------------------------
# 1. System Restore
# ------------------------------------------------------------
Write-Log "Configuring System Restore..."

try {
    # Enable System Restore on system drive
    Enable-ComputerRestore -Drive "C:\" -ErrorAction Stop

    # Create an initial restore point
    Checkpoint-Computer -Description "Initial Bootstrap Restore Point" -RestorePointType "MODIFY_SETTINGS"

    Write-Log "System Restore configured."
}
catch {
    Write-Log "Failed to configure System Restore: $($_.Exception.Message)" "WARN"
}

# ------------------------------------------------------------
# 2. Power Plan
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

Write-Log "Windows configuration complete."

# ------------------------------------------------------------
# 3. Scheduled Task: Daily Winget Updater (Idle Trigger)
# ------------------------------------------------------------
Write-Log "Configuring daily winget update task..."

try {
    $taskName = "WinBootstrap-WingetUpdate"
    $taskPath = "\WinBootstrap"

    # Remove existing task if present
    if (Get-ScheduledTask -TaskName $taskName -TaskPath $taskPath -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Confirm:$false
    }

    # Create folder if missing (COM API, works on all Windows versions)
    $service = New-Object -ComObject "Schedule.Service"
    $service.Connect()

    $rootFolder = $service.GetFolder("\")
    try {
        $null = $rootFolder.GetFolder($taskPath)
    } catch {
        $rootFolder.CreateFolder($taskPath) | Out-Null
    }

    # Action: run PowerShell silently
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument @(
        "-NoProfile",
        "-WindowStyle Hidden",
        "-Command",
        "winget upgrade --all --silent --accept-package-agreements --accept-source-agreements"
    ) -WorkingDirectory "C:\Windows\System32"

    # Trigger: when system is idle, repeat every 1 day
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $trigger.IdleDuration = "PT10M"       # wait 10 minutes of idle
    $trigger.RepetitionInterval = "P1D"   # run at most once per day

    # Settings
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries:$false `
                                             -DontStopIfGoingOnBatteries:$false `
                                             -StartWhenAvailable `
                                             -RunOnlyIfIdle `
                                             -IdleDuration "PT10M" `
                                             -IdleWaitTimeout "PT1H"

    # Register task
    Register-ScheduledTask -TaskName $taskName `
                           -TaskPath $taskPath `
                           -Action $action `
                           -Trigger $trigger `
                           -Settings $settings `
                           -RunLevel Highest `
                           -Description "Automatically updates winget packages once per day when the system is idle." `
                           | Out-Null

    Write-Log "Winget update task configured."
}
catch {
    Write-Log "Failed to configure winget update task: $($_.Exception.Message)" "WARN"
}