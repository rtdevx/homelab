# Config
$uri = 'https://asg-lt1-uat.aws.skynetx.uk/app1/index.html'
$concurrency = 3
$rounds = 200
$delayBetweenRoundsSec = 2
$timeoutSeconds = 30
$outputCsv = "loadtest_results.csv"

# CSV header (overwrite if exists)
"Round,Index,TimestampUtc,StatusCode,DurationMs,Success,Error" | Out-File -FilePath $outputCsv -Encoding UTF8

# Job script: runs one HTTP GET and returns CSV line and PSCustomObject
$jobScript = {
    param($uri, $index, $round, $timeoutSeconds)
    $ts = [DateTime]::UtcNow.ToString("o")
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $status = $null
    $err = $null
    $success = $false

    try {
        $req = [System.Net.WebRequest]::Create($uri)
        $req.Method = "GET"
        $req.Timeout = $timeoutSeconds * 1000
        $resp = $req.GetResponse()
        $sw.Stop()
        $status = 200
        $success = $true
        $resp.Close()
    } catch {
        $sw.Stop()
        $success = $false
        $err = $_.Exception.Message -replace ",",";"
        try {
            if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
                $status = [int]$_.Exception.Response.StatusCode
            } else {
                $status = $null
            }
        } catch {
            $status = $null
        }
    }

    # Build CSV-safe values
    if ($status -ne $null) { $statusField = $status } else { $statusField = "" }
    if ($err -ne $null -and $err -ne "") { $errField = $err } else { $errField = "" }
    $line = "{0},{1},{2},{3},{4},{5},{6}" -f $round, $index, $ts, $statusField, $sw.ElapsedMilliseconds, $success, $errField

    # Output: first the CSV line (string), then a PSCustomObject for summary
    ,$line
    ,[PSCustomObject]@{
        Round = $round
        Index = $index
        TimestampUtc = $ts
        StatusCode = if ($status -ne $null) { $status } else { $null }
        DurationMs = $sw.ElapsedMilliseconds
        Success = $success
        Error = if ($err -ne $null -and $err -ne "") { $err } else { $null }
    }
}

for ($round = 1; $round -le $rounds; $round++) {
    Write-Host "Round $round/$rounds — launching $concurrency simultaneous requests to $uri"

    # Start exactly $concurrency jobs
    $jobs = for ($i = 1; $i -le $concurrency; $i++) {
        Start-Job -ScriptBlock $jobScript -ArgumentList $uri, $i, $round, $timeoutSeconds
    }

    # Wait and collect results; remove jobs after receiving
    $results = Receive-Job -Job $jobs -Wait -AutoRemoveJob | Sort-Object Index

    # Write CSV lines (Receive-Job returns strings and PSCustomObjects; strings are CSV lines)
    foreach ($r in $results) {
        if ($r -is [string]) {
            $r | Out-File -FilePath $outputCsv -Encoding UTF8 -Append
        }
    }

    # Extract PSCustomObjects for summary
    $objs = ($results | Where-Object { $_ -is [PSCustomObject] }) | Sort-Object Index

    # Display per-request results for this round
    if ($objs) {
        $objs | Format-Table Index, StatusCode, DurationMs, Success, Error -AutoSize
    } else {
        Write-Host "No PSCustomObject results returned for round $round"
    }

    # Summary
    $total = if ($objs) { $objs.Count } else { 0 }
    $successCount = if ($objs) { ($objs | Where-Object { $_.Success }).Count } else { 0 }
    $failedCount = $total - $successCount
    $avgMs = if ($total -gt 0) { [math]::Round(($objs | Measure-Object -Property DurationMs -Average).Average,2) } else { 0 }
    $minMs = if ($total -gt 0) { ($objs | Measure-Object -Property DurationMs -Minimum).Minimum } else { 0 }
    $maxMs = if ($total -gt 0) { ($objs | Measure-Object -Property DurationMs -Maximum).Maximum } else { 0 }

    Write-Host ("  Summary: Total={0} Successful={1} Failed={2} AvgMs={3} MinMs={4} MaxMs={5}" -f $total, $successCount, $failedCount, $avgMs, $minMs, $maxMs)

    if ($round -lt $rounds) { Start-Sleep -Seconds $delayBetweenRoundsSec }
}

Write-Host "Load test complete. Results written to $outputCsv"