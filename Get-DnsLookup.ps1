# 1. Define paths (Input/Output on your Desktop)
$desktop = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
$inputFile  = Join-Path $desktop "ipadr.txt"
$outputFile = Join-Path $desktop "dns_results.txt"

# 2. Validate input existence
if (-not (Test-Path $inputFile)) { 
    Write-Host "Error: Could not find ipadr.txt on your Desktop." -ForegroundColor Red
    return 
}

# 3. Add a clear separator for the current run
"`n--- Run Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ---" | Out-File $outputFile -Append

# 4. Process the list
Write-Host "Processing DNS lookups from $inputFile..." -ForegroundColor Cyan

Get-Content $inputFile | ForEach-Object {
    $line = $_.Trim()
    if ($line) {
        try {
            # Use Resolve-DnsName to perform the query
            $lookup = Resolve-DnsName $line -ErrorAction Stop | Select-Object -First 1
            
            # Logic: If PTR (Reverse) returns NameHost, use it. Otherwise, use IPAddress.
            $val = if ($lookup.NameHost) { $lookup.NameHost } else { $lookup.IPAddress }
        } catch {
            $val = "No record found"
        }
        
        # Log the result
        "$line -> $val" | Out-File $outputFile -Append
        Write-Host "Processed: $line -> $val"
    }
}

Write-Host "`nSuccess! Results saved to: $outputFile" -ForegroundColor Green