# 1. Dependency Check
if (-not (Get-Module -ListAvailable ActiveDirectory)) {
    Write-Host "CRITICAL: Active Directory module not found. Please install RSAT." -ForegroundColor Red
    return
}

# 2. Input
$SearchTerm = Read-Host "Enter the Name, Username, or ID to search for (use * for wildcards)"
$Type       = Read-Host "Search for [1] User or [2] Group?"

Write-Host "`nSearching Active Directory (LDAP)..." -ForegroundColor Cyan

try {
    if ($Type -eq "1") {
        # Search User using LDAP Filter (The most reliable method)
        # It looks for the term in name, samAccountName, and userPrincipalName
        $LDAPFilter = "(&(|(name=*$SearchTerm*)(samAccountName=*$SearchTerm*)(userPrincipalName=*$SearchTerm*)))"
        $Results = Get-ADUser -LDAPFilter $LDAPFilter -Properties EmailAddress, Enabled | 
                   Select-Object Name, SamAccountName, Enabled, EmailAddress
    } 
    else {
        # Search Group using LDAP Filter
        $LDAPFilter = "(&(objectCategory=group)(|(name=*$SearchTerm*)(samAccountName=*$SearchTerm*)))"
        $Results = Get-ADGroup -LDAPFilter $LDAPFilter | 
                   Select-Object Name, SamAccountName, GroupCategory, GroupScope
    }

    # 3. Output
    if ($Results) {
        Write-Host "`nFound $($Results.Count) match(es):" -ForegroundColor Green
        $Results | Format-Table -AutoSize
    } else {
        Write-Host "No results found for '$SearchTerm'." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n"
Read-Host "Press Enter to return to menu..."