# ==========================================
# MUNCH Toolkit: 7-Zip Comprehensive Audit
# ==========================================

# 1. Setup paths relative to the script location
$MunchRoot   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SourceFile  = Join-Path $MunchRoot "Input\7z.txt"
$OutputDir   = Join-Path $MunchRoot "Output"
$ReportPath  = Join-Path $OutputDir "7Zip_Comprehensive_Audit.csv"

# 2. Check for Source and Ensure Output directory
if (-not (Test-Path $SourceFile)) {
    Write-Host "CRITICAL: 'Input\7z.txt' not found." -ForegroundColor Red
    return
}
if (-not (Test-Path $OutputDir)) { New-Item -Path $OutputDir -ItemType Directory | Out-Null }

# 3. Load computers and request user confirmation
$Computers = Get-Content $SourceFile | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Select-Object -Unique

Write-Host "`n--- MUNCH Audit Configuration ---" -ForegroundColor Yellow
Write-Host "Source File: $SourceFile"
Write-Host "Servers Detected: $($Computers.Count)"
Write-Host "Output Path: $ReportPath"
Write-Host "---------------------------------" -ForegroundColor Yellow

$Confirm = Read-Host "Proceed with audit? (y/n)"
if ($Confirm -ne 'y') { Write-Host "Audit cancelled." -ForegroundColor Gray; return }

# 4. Define the Audit Logic (The ScriptBlock)
$ScriptBlock = {
    $Result = [PSCustomObject]@{ ComputerName = $env:COMPUTERNAME; Status = "Not Found"; Version = "N/A"; PathUsed = "None" }
    
    # Registry Check
    $RegPaths = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip", 
                  "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip")
    foreach ($Path in $RegPaths) {
        if (Test-Path $Path) {
            $App = Get-ItemProperty $Path
            $Result.Status = "Installed (Registry)"
            $Result.Version = $App.DisplayVersion
            $Result.PathUsed = $Path
            return $Result 
        }
    }
    
    # File System Check (Fallback)
    $FilePaths = @("C:\Program Files\7-Zip\7z.exe", "C:\Program Files (x86)\7-Zip\7z.exe")
    foreach ($FilePath in $FilePaths) {
        if (Test-Path $FilePath) {
            $Result.Status = "Installed (File System)"
            $Result.Version = (Get-Item $FilePath).VersionInfo.FileVersion
            $Result.PathUsed = $FilePath
            return $Result
        }
    }
    return $Result
}

# 5. Execute Audit
Write-Host "`nRunning audit... please wait." -ForegroundColor Cyan
$Results = Invoke-Command -ComputerName $Computers -ScriptBlock $ScriptBlock -ErrorAction SilentlyContinue | Select-Object ComputerName, Status, Version, PathUsed

# 6. Export Results
$Results | Export-Csv -Path $ReportPath -NoTypeInformation
Write-Host "`nAudit Complete! Report saved to:" -ForegroundColor Green
Write-Host $ReportPath -ForegroundColor White