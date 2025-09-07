# Run as Administrator
# PowerShell DFIR Workstation Setup Script
# Note: Requires winget (Windows Package Manager)

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

# Ensure TLS 1.2 for downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "=== Installing DFIR tools... ==="

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
# Event Log Explorer (trial/freeware version)
# -----------------------------
Write-Host "Installing Event Log Explorer..."
winget install --id FSProLabs.EventLogExplorer -e --source winget

# -----------------------------
# Sysinternals Suite
# -----------------------------
Write-Host "Installing Sysinternals Suite..."
winget install --id Microsoft.SysinternalsSuite -e --source winget

# -----------------------------
# Notepad++
# -----------------------------
Write-Host "Installing Notepad++..."
winget install --id Notepad++.Notepad++ -e --source winget

# -----------------------------
# Wireshark
# -----------------------------
Write-Host "Installing Wireshark..."
winget install --id WiresharkFoundation.Wireshark -e --source winget

# # -----------------------------
# # Arsenal Image Mounter
# # -----------------------------
# Write-Host "Installing Arsenal Image Mounter..."
# Invoke-WebRequest -Uri "https://arsenalrecon.com/downloads/AIMSetup.msi" -OutFile "$env:TEMP\AIMSetup.msi"
# Start-Process msiexec.exe -ArgumentList "/i `"$env:TEMP\AIMSetup.msi`" /quiet /norestart" -Wait

# # -----------------------------
# # KAPE
# # -----------------------------
# Write-Host "Installing KAPE..."
# Invoke-WebRequest -Uri "https://s3.amazonaws.com/kroll-kape/KAPE.zip" -OutFile "$env:TEMP\KAPE.zip"
# Expand-Archive "$env:TEMP\KAPE.zip" -DestinationPath "C:\Tools\KAPE" -Force

# # -----------------------------
# # FTK Imager
# # -----------------------------
# Write-Host "Installing FTK Imager..."
# Invoke-WebRequest -Uri "https://ad-pdf.s3.amazonaws.com/FTK-Imager-4.7.1.exe" -OutFile "$env:TEMP\FTKImager.exe"
# Start-Process "$env:TEMP\FTKImager.exe" -ArgumentList "/quiet /norestart" -Wait

Write-Host "=== DFIR Workstation setup complete! ==="
