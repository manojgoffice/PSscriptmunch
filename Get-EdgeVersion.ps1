# 1. Configuration
$Desktop = [Environment]::GetFolderPath("Desktop")
$HostFile = Join-Path $Desktop "edge.txt"
$OutputFile = Join-Path $Desktop "Edge_Version_Report.txt"
$Timeout = 10 # Seconds

if (-not (Test-Path $HostFile)) {
    [System.Windows.Forms.MessageBox]::Show("Error: 'edge.txt' not found on Desktop.")
    exit
}

$Hosts = Get-Content $HostFile | Where-Object { $_.Trim() -ne "" }
$Results = @()

Write-Host "Querying Edge versions on $($Hosts.Count) servers..." -ForegroundColor Cyan

foreach ($Computer in $Hosts) {
    $Computer = $Computer.Trim()
    
    # Run the query as a background job for performance
    $Job = Invoke-Command -ComputerName $Computer -ScriptBlock {
        $Path = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
        if (Test-Path $Path) {
            return (Get-Item $Path).VersionInfo.FileVersion
        } else {
            return "NOT INSTALLED"
        }
    } -AsJob

    # Wait for the job or timeout
    $Wait = Wait-Job $Job -Timeout $Timeout

    if ($null -eq $Wait) {
        $Results += "${Computer}: TIMED OUT"
        Write-Host "   [!] ${Computer} timed out." -ForegroundColor Yellow
        Stop-Job $Job; Remove-Job $Job
    } else {
        try {
            $Version = Receive-Job $Job -ErrorAction Stop
            $Results += "${Computer}: $Version"
            Write-Host "   [+] ${Computer}: $Version" -ForegroundColor Green
        } catch {
            $Results += "${Computer}: OFFLINE/ACCESS DENIED"
            Write-Host "   [-] ${Computer}: FAILED/OFFLINE" -ForegroundColor Red
        }
        Remove-Job $Job
    }
}

# 3. Export Report
$Results | Out-File -FilePath $OutputFile -Force
Write-Host "`nExtraction Complete! Report saved to: $OutputFile" -ForegroundColor White -BackgroundColor DarkGreen