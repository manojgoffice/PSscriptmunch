# 1. Setup paths
$MunchRoot   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SourceFile  = Join-Path $MunchRoot "Input\HWreport.txt"
$ReportFile  = Join-Path $MunchRoot "Output\Hardware-Inventory.txt"

# 2. Check for source file
if (-not (Test-Path $SourceFile)) {
    Write-Host "CRITICAL: Input file not found at $SourceFile" -ForegroundColor Red; return
}

# 3. Optional: Ask for Credentials (only if your current user lacks permissions)
$UseCreds = Read-Host "Use specific credentials? (y/n)"
$Creds = if ($UseCreds -eq 'y') { Get-Credential } else { $null }

# 4. Prepare Report
$Hostnames = Get-Content $SourceFile
"--- Hardware Inventory Report: $(Get-Date) ---" | Out-File -FilePath $ReportFile -Append

foreach ($Computer in $Hostnames) {
    Write-Host "Auditing: $Computer..." -ForegroundColor Cyan
    
    # Check if server is reachable before trying to connect
    if (-not (Test-Connection -ComputerName $Computer -Count 1 -Quiet)) {
        "$Computer : OFFLINE" | Out-File -FilePath $ReportFile -Append
        Write-Host "  -> Offline" -ForegroundColor Red
        continue
    }

    try {
        # Execution with Credential support
        $Params = @{
            ComputerName = $Computer
            ScriptBlock  = { Get-CimInstance Win32_Processor }
            ErrorAction  = 'Stop'
        }
        if ($Creds) { $Params.Credential = $Creds }
        
        $cpu = Invoke-Command @Params
        
        $Output = @"
Server: $Computer
  - Sockets: $($cpu.Count)
  - Physical Cores: $(($cpu | Measure-Object NumberOfCores -Sum).Sum)
  - Logical Processors: $(($cpu | Measure-Object NumberOfLogicalProcessors -Sum).Sum)
-------------------------------------------------------
"@
        $Output | Out-File -FilePath $ReportFile -Append
        Write-Host "  -> Success" -ForegroundColor Green
    }
    catch {
        "$Computer : FAILED - $($_.Exception.Message)" | Out-File -FilePath $ReportFile -Append
        Write-Host "  -> Failed: $($_.Exception.Message.Substring(0,20))..." -ForegroundColor Yellow
    }
}

Write-Host "`nInventory complete. Check Output\Hardware-Inventory.txt" -ForegroundColor Green
Read-Host "Press Enter to return to menu..."