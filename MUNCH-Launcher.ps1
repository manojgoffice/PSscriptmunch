function Show-Menu {
    Clear-Host
    Write-Host "`n"
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "           MUNCH TOOLKIT - COMMAND CENTER               " -ForegroundColor Yellow
    Write-Host "========================================================" -ForegroundColor Cyan
    
    # Get all .ps1 files, excluding the launcher
    $Scripts = Get-ChildItem -Filter *.ps1 | Where-Object { $_.Name -ne "MUNCH-Launcher.ps1" }
    
    for ($i = 0; $i -lt $Scripts.Count; $i++) {
        # This replaces the messy extension with nothing for the display
        $DisplayName = $Scripts[$i].Name -replace "\.ps1.*", "" 
        $FormattedIndex = ($i + 1).ToString("00")
        Write-Host " [$FormattedIndex] $DisplayName" -ForegroundColor White
    }
    
    Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
    Write-Host " [Q] Quit" -ForegroundColor Red
    Write-Host "`n"
}

# Launcher Execution Loop
do {
    Show-Menu
    $choice = Read-Host "Select a tool number"
    if ($choice -eq 'Q') { break }
    
    $Scripts = Get-ChildItem -Filter *.ps1 | Where-Object { $_.Name -ne "MUNCH-Launcher.ps1" }
    $index = [int]$choice - 1
    
    if ($index -ge 0 -and $index -lt $Scripts.Count) {
        Write-Host "`n>>> Running: $($Scripts[$index].Name)...`n" -ForegroundColor Green
        & $Scripts[$index].FullName
        Write-Host "`n"
        Read-Host "Press Enter to return to menu..."
    }
} while ($true)