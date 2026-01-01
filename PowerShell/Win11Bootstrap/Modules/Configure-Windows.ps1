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