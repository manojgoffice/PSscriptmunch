# 1. Configuration
$DesktopPath    = [Environment]::GetFolderPath("Desktop")
$ServerListPath = Join-Path -Path $DesktopPath -ChildPath "serverSNA.txt"
$OutputPath     = Join-Path -Path $DesktopPath -ChildPath "Service_Audit_Status.txt"
$ServiceSearch  = "*AgentClientCollector*"

# 2. Validation
if (-not (Test-Path $ServerListPath)) { 
    [System.Windows.Forms.MessageBox]::Show("Error: 'serverSNA.txt' not found on Desktop.")
    exit 
}

$Servers = Get-Content $ServerListPath | Where-Object { $_.Trim() -ne "" }
$Report  = @("Service Audit Report - $(Get-Date)", "------------------------------------------------------------")

Write-Host "Auditing Service Status on $($Servers.Count) servers..." -ForegroundColor Cyan

# 3. Execution Loop
foreach ($Server in $Servers) {
    $Server = $Server.Trim()
    
    try {
        $StatusInfo = Invoke-Command -ComputerName $Server -ErrorAction Stop -ArgumentList $ServiceSearch -ScriptBlock {
            param($sSearch)
            $svc = Get-Service | Where-Object { $_.Name -like $sSearch -or $_.DisplayName -like $sSearch }
            if ($null -eq $svc) { return "NOT_INSTALLED" }
            return "$($svc.Status) (StartType: $($svc.StartType))"
        }

        # Console Visualization
        Write-Host "[$Server] : " -NoNewline
        if ($StatusInfo -like "*Running*") {
            Write-Host "RUNNING" -ForegroundColor Green
        } elseif ($StatusInfo -eq "NOT_INSTALLED") {
            Write-Host "NOT FOUND" -ForegroundColor Yellow
        } else {
            Write-Host "STOPPED" -ForegroundColor Red
        }

        $Report += "$Server | Status: $StatusInfo"
    } 
    catch {
        Write-Host "[$Server] : UNREACHABLE" -ForegroundColor Gray
        $Report += "$Server | Status: OFFLINE or WinRM Blocked"
    }
}

# 4. Finalize
$Report += "------------------------------------------------------------"
$Report | Out-File $OutputPath
Write-Host "`nDetailed report saved to: $OutputPath" -ForegroundColor Green