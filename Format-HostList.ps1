Add-Type -AssemblyName System.Windows.Forms

# 1. Open a file selection dialog
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$FileBrowser.Filter = "Text Files (*.txt)|*.txt"
$FileBrowser.Title = "Select the Host List file to clean"

if ($FileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $FilePath = $FileBrowser.FileName
    
    # 2. Process the file
    $Hosts = Get-Content $FilePath
    $UniqueHosts = $Hosts | Where-Object { $_.Trim() -ne "" } | Select-Object -Unique | Sort-Object
    
    # 3. Save the clean list back to the same file
    $UniqueHosts | Set-Content $FilePath
    
    [System.Windows.Forms.MessageBox]::Show("Cleanup complete! `nOriginal: $($Hosts.Count)`nUnique: $($UniqueHosts.Count)")
}