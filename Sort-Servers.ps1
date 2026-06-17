# --- Standardized Pathing ---
$MunchRoot      = Split-Path -Parent $MyInvocation.MyCommand.Definition
$InputFolder    = Join-Path $MunchRoot "Input"
$ServerListFile = Join-Path $InputFolder "serverlist.txt"

# Ensure the Input folder exists
if (-not (Test-Path $InputFolder)) { New-Item -ItemType Directory -Path $InputFolder | Out-Null }

# Define your organized output files inside the Input folder as well
$WindowsFile = Join-Path $InputFolder "Windows_Servers.txt"
$LinuxFile   = Join-Path $InputFolder "Linux_Servers.txt"
$UnknownFile = Join-Path $InputFolder "Unknown_Servers.txt"
$FailedFile  = Join-Path $InputFolder "Connection_Failed.txt"

# Reset files
Clear-Content $WindowsFile, $LinuxFile, $UnknownFile, $FailedFile -ErrorAction SilentlyContinue

if (-not (Test-Path $ServerListFile)) {
    Write-Host "CRITICAL: 'serverlist.txt' not found in $InputFolder" -ForegroundColor Red
    return
}

$Servers = Get-Content $ServerListFile | Where-Object { $_.Trim() -ne "" }
$Total = $Servers.Count

Write-Host "Scanning $Total servers from $ServerListFile..." -ForegroundColor Cyan

foreach ($Server in $Servers) {
    $Server = $Server.Trim()
    
    # Heuristic Checks
    $WinCheck = Test-NetConnection -ComputerName $Server -Port 3389 -InformationLevel Quiet
    $LinCheck = if (-not $WinCheck) { Test-NetConnection -ComputerName $Server -Port 22 -InformationLevel Quiet } else { $false }

    # Sort Results
    if ($WinCheck) {
        Add-Content -Path $WindowsFile -Value $Server
        Write-Host "[WIN] $Server" -ForegroundColor Green
    } elseif ($LinCheck) {
        Add-Content -Path $LinuxFile -Value $Server
        Write-Host "[LIN] $Server" -ForegroundColor Yellow
    } else {
        if (-not (Test-Connection -ComputerName $Server -Count 1 -Quiet)) {
            Add-Content -Path $FailedFile -Value $Server
            Write-Host "[FAIL] $Server" -ForegroundColor Red
        } else {
            Add-Content -Path $UnknownFile -Value $Server
            Write-Host "[???] $Server" -ForegroundColor Magenta
        }
    }
}