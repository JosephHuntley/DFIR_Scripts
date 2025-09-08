# Run as Administrator
# PowerShell DFIR Workstation Setup Script
# Note: Requires winget (Windows Package Manager)

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
    Write-Host "Please run this script as Administrator."
    exit
}

$WshShell = New-Object -ComObject WScript.Shell

# Set timezone to UTC to ensure default time format.
Write-Host "Setting UTC Timezone"
Set-TimeZone -Id "UTC"

# Show hidden files
Write-Host "Show Hidden Files"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name Hidden -Value 1

# Create cases and tools folder
Write-Host "Creating folders for cases and tools"
mkdir "C:\Cases"
mkdir "C:\Tools"

# Disable “Cloud-delivered protection” and “Automatic sample submission”
Write-Host "Disabling Cloud-delivered protection and Automatic sample submission"
Set-MpPreference -MAPSReporting 0
Set-MpPreference -SubmitSamplesConsent 2
Set-MpPreference -DisableBlockAtFirstSeen $true

# Exclude case evidence folder
Write-Host "Excluding folders cases and tools from Defender"
Add-MpPreference -ExclusionPath "C:\Cases"
# Exclude forensic tools folder
Add-MpPreference -ExclusionPath "C:\Tools"

# -----------------------------
# Disable Copilot
# -----------------------------
# Create the registry path if it doesn't exist
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Copilot"
if (-not (Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Set 'Enable' to 0 to disable Copilot
New-ItemProperty -Path $RegPath -Name "Enable" -PropertyType DWORD -Value 0 -Force | Out-Null

Write-Host "Copilot has been disabled. Please restart your PC for changes to take effect."

# -----------------------------
# Remove shortcuts from Desktop
# -----------------------------

$Desktop = [Environment]::GetFolderPath("Desktop")

# Remove only shortcut files
Get-ChildItem -Path $Desktop -Filter *.lnk -Force | Remove-Item -Force

Write-Host "All shortcut icons on the desktop have been removed."


# Define folders and shortcut names
$Folders = @{
    "C:\Tools" = "Tools"
    "C:\Cases" = "Cases"
}

foreach ($FolderPath in $Folders.Keys) {
    $ShortcutName = $Folders[$FolderPath] + ".lnk"
    $ShortcutPath = Join-Path $Desktop $ShortcutName

    # Create shortcut
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $FolderPath
    $Shortcut.WorkingDirectory = $FolderPath
    $Shortcut.Save()

    Write-Host "Shortcut created for $FolderPath on desktop."
}

Get-AppxPackage -AllUsers *Xbox* | Remove-AppxPackage

# Set Apps to dark
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0

# Set System (taskbar, start menu) to dark
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0

Write-Host "Dark mode enabled. You may need to sign out and sign back in to apply all changes."

Write-Host "=== Installing DFIR tools... ==="

# Ensure TLS 1.2 for downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Check for winget or throw error
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget not found. Install App Installer from Microsoft Store first."
    exit 1
}

# -----------------------------
# Eric Zimmerman's Tools
# -----------------------------
Write-Host "Installing Eric Zimmerman’s tools..."
Invoke-WebRequest -Uri "https://f001.backblazeb2.com/file/EricZimmermanTools/Get-ZimmermanTools.zip" -OutFile "$env:TEMP\Get-ZimmermanTools.zip"
Expand-Archive "$env:TEMP\Get-ZimmermanTools.zip" -DestinationPath "C:\Tools\EricZimmerman" -Force
Set-Location "C:\Tools\EricZimmerman"
& ".\Get-ZimmermanTools.ps1" -Dest "C:\Tools\EricZimmerman"

# -----------------------------
# RegRipper 3.0
# -----------------------------
Write-Host "Installing RegRipper..."
Invoke-WebRequest -Uri "https://github.com/keydet89/RegRipper3.0/archive/refs/heads/master.zip" -OutFile "$env:TEMP\regripper.zip"
Expand-Archive "$env:TEMP\regripper.zip" -DestinationPath "C:\Tools\RegRipper" -Force

# -----------------------------
# Notepad++
# -----------------------------
Write-Host "Installing Notepad++..."
winget install --id Notepad++.Notepad++ -e --source winget

# Add shortcut
$shortcut = $WshShell.CreateShortcut("C:\Tools\Notepad++.lnk")
$shortcut.TargetPath = "C:\Program Files\Notepad++\notepad++.exe"
$shortcut.Save()

# -----------------------------
# Wireshark
# -----------------------------
Write-Host "Installing Wireshark..."
winget install --id WiresharkFoundation.Wireshark -e --source winget

# Add shortcut
$shortcut = $WshShell.CreateShortcut("C:\Tools\Wireshark.lnk")
$shortcut.TargetPath = "C:\Program Files\Wireshark\Wireshark.exe"
$shortcut.Save()

# -----------------------------
# Arsenal Image Mounter
# -----------------------------
Write-Host "Installing Arsenal Image Mounter..."
Invoke-WebRequest -Uri "https://arsenalrecon.com/downloads/AIMSetup.msi" -OutFile "$env:TEMP\AIMSetup.msi"
Start-Process msiexec.exe -ArgumentList "/i `"$env:TEMP\AIMSetup.msi`" /quiet /norestart" -Wait

# -----------------------------
# Firefox
# -----------------------------

# Install Firefox via winget
Write-Host "Installing Mozilla Firefox..."
winget install --id Mozilla.Firefox -e --source winget

# Path to Firefox executable (default installation path)
$FirefoxPath = "C:\Program Files\Mozilla Firefox\firefox.exe"

# Check if the executable exists
if (-Not (Test-Path $FirefoxPath)) {
    Write-Host "Firefox installation path not found. Please verify installation."
    exit
}

# Pin Firefox to Taskbar using PowerShell
$Shell = New-Object -ComObject Shell.Application
$Folder = $Shell.Namespace((Split-Path $FirefoxPath))
$Item = $Folder.ParseName((Split-Path $FirefoxPath -Leaf))
$Item.InvokeVerb("taskbarpin")

Write-Host "Firefox installed and pinned to the taskbar successfully."

Write-Host "=== DFIR Workstation setup complete! ==="
