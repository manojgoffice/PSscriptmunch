# ==========================================================
# MUNCH Toolkit: Notepad++ Version Audit
# ==========================================================

# 1. Setup paths relative to script location
$MunchRoot   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SourceFile  = Join-Path $MunchRoot "Input\npp.txt"
$OutputDir   = Join-Path $MunchRoot "Output"
$ReportPath  = Join-Path $OutputDir "Notepad++_Version_Audit.txt"

# 2. Ensure Output folder exists
if (-not (Test-Path $OutputDir)) { New-Item -Path $OutputDir -ItemType Directory | Out-Null }

# 3. Check for Source and Confirm
if (-not (Test-Path $SourceFile)) { 
    Write-Host "CRITICAL: 'Input\npp.txt' not found." -ForegroundColor Red; return 
}

$Servers = Get-Content $SourceFile | Where-Object { $_.Trim() -ne "" } | Select-Object -Unique

Write-Host "`n--- MUNCH Audit Configuration ---" -ForegroundColor Yellow
Write-Host "Source File: $SourceFile"
Write-Host "Servers to Audit: $($Servers.Count)"
Write-Host "---------------------------------" -ForegroundColor Yellow

if ((Read-Host "Proceed with audit? (y/n)") -ne 'y') { return }

# 4. Initialize Report
"Server`tVersion`tSource" | Out-File -FilePath $ReportPath -Encoding utf8

# 5. Audit Loop
foreach ($Server in $Servers) {
    $Server = $Server.Trim()
    Write-Host "`n>>> Auditing: $Server" -ForegroundColor Cyan

    try {
        $Audit = Invoke-Command -ComputerName $Server -ErrorAction Stop -ScriptBlock {
            # Registry Strategy
            $RegPaths = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", 
                          "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*")
            $RegMatch = Get-ItemProperty $RegPaths -ErrorAction SilentlyContinue | 
                        Where-Object { $_.DisplayName -like "*Notepad++*" } | 
                        Select-Object -First 1
            
            if ($null -ne $RegMatch) { return @{ Version = $RegMatch.DisplayVersion; Source = "Registry" } }

            # File System Fallback
            $DirPaths = @("${env:ProgramFiles}\Notepad++\notepad++.exe", 
                          "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe")
            foreach ($Path in $DirPaths) {
                if (Test-Path $Path) {
                    $Ver = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($Path).FileVersion
                    return @{ Version = $Ver; Source = "File Path" }
                }
            }
            return @{ Version = "Not Found"; Source = "None" }
        }

        $Color = if ($Audit.Version -eq "Not Found") { "Yellow" } else { "Green" }
        Write-Host "   Version: $($Audit.Version) (via $($Audit.Source))" -ForegroundColor $Color
        "$Server`t$($Audit.Version)`t$($Audit.Source)" | Out-File -FilePath $ReportPath -Append -Encoding utf8
    }
    catch {
        Write-Host "   [!] ERROR: $($_.Exception.Message.Substring(0,40))..." -ForegroundColor Red
        "$Server`tOFFLINE/ERROR`tN/A" | Out-File -FilePath $ReportPath -Append -Encoding utf8
    }
}

Write-Host "`nAudit finished. Report saved to: $ReportPath" -ForegroundColor Green