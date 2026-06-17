# PSscriptmunch
basic ps scripts for the server admin
# PSscriptmunch

A collection of professional PowerShell automation scripts designed for system administrators to manage and audit server infrastructure efficiently.

## 🚀 Overview
The **MUNCH Toolkit** is a portable, folder-based framework designed to simplify daily administrative tasks. It provides automated solutions for auditing software versions, monitoring services, and managing hardware reports across multiple remote servers.

## 📂 Folder Structure
```text
PSscriptmunch/
├── Input/              # Place your server lists (.txt) here
├── Output/             # Audit reports (.csv/.txt) are saved here
├── Audit-7Zip.ps1      # Audit 7-Zip versions across remote servers
├── Audit-NotepadVersion.ps1 # Audit Notepad++ versions
├── Get-HardwareReport.ps1   # Generate hardware inventory
├── MUNCH-Launcher.ps1  # Main entry point for the toolkit
└── ...
🛠 Features
Remote Auditing: Uses Invoke-Command and CIM sessions to query remote Windows servers.
Portability: Scripts use relative pathing ($PSScriptRoot), allowing you to move the folder anywhere without breaking dependencies.
Data Safety: Input and Output folders are standardized to keep server lists and reports organized.
Professional Reporting: Results are exported to clean CSV/Text formats for easy analysis in Excel.

⚙️ How to Use
Prepare your Environment: Ensure you have the Input and Output directories in your root folder.
Add Targets: Create a .txt file (e.g., npp.txt) inside the Input folder and add one server hostname per line.

Execute: Open PowerShell as Administrator and run the desired script:

PowerShell
.\MUNCH-Launcher.ps1
Review: Check the Output folder for the generated report.

🛡 Security Best Practices
Execution Policy: You may need to run Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process in your PowerShell session.
Privileges: Always run these scripts as Administrator to ensure the scripts can access the Windows Registry and remote management services.
Git Safety: Your Input and Output folders are intended for local use. Avoid committing your private server list files to GitHub.

📝 Scripts Included
Audit-7Zip.ps1: Scans registry and file system for 7-Zip versions.
Audit-NotepadVersion.ps1: Audits Notepad++ installation status.
Audit-SnowServiceStatus.ps1: Monitors service status for ServiceNow/related agents.
Get-HardwareReport.ps1: Gathers CPU and hardware inventory.
Search-AD.ps1: Helper to find machines in Active Directory.
