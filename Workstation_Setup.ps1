# Set timezone to UTC to ensure default time format.
Set-TimeZone -Id "UTC"

# Show hidden files
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name Hidden -Value 1

# Create cases and tools folder
mkdir "C:\Cases"
mkdir "C:\Tools"

# Temporarily disable real-time protection
Set-MpPreference -DisableRealtimeMonitoring $true

# Disable “Cloud-delivered protection” and “Automatic sample submission”
Set-MpPreference -MAPSReporting Disabled
Set-MpPreference -SubmitSamplesConsent NeverSend
Set-MpPreference -DisableBlockAtFirstSeen $true

# Exclude case evidence folder
Add-MpPreference -ExclusionPath "C:\Cases"
# Exclude forensic tools folder
Add-MpPreference -ExclusionPath "C:\Tools"
