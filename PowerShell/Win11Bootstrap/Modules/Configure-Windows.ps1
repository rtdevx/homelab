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