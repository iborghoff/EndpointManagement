Start-Transcript "$($env:ProgramData)\DeviceConfiguration\DeviceConfiguration.log"

# Create folder and tag file so Intune knows this was installed
if (-not (Test-Path "$($env:ProgramData)\DeviceConfiguration")) {
    New-Item -Path $env:ProgramData -Name 'DeviceConfiguration' -ItemType 'directory' -Force
}
Set-Content -Path "$($env:ProgramData)\DeviceConfiguration\DeviceConfiguration.ps1.tag" -Value "Installed"

$geoid = "_" + $(Get-WinHomeLocation).GeoId
Write-Host "Geo location: $geoid"

# Load the Config.xml
$installFolder = "$PSScriptRoot\"
Write-Host "Install folder: $installFolder"
Write-Host "Loading configuration: $($installFolder)Config.xml"
[Xml]$config = Get-Content "$($installFolder)Config.xml"

#region - Configure system
# Remove specified provisioned apps if they exist
Write-Host "Removing specified in-box provisioned apps"
$apps = Get-AppxProvisionedPackage -online
$config.Config.RemoveApps.App | ForEach-Object {
    $current = $_
    $apps | Where-Object { $_.DisplayName -eq $current } | ForEach-Object {
        Write-Host "Removing provisioned app: $current"
        $_ | Remove-AppxProvisionedPackage -Online | Out-Null
    }
}

# Set registered user and organization
Write-Host "Configuring registered user information"
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOwner /t REG_SZ /d "$($config.Config.RegisteredOwner)" /f /reg:64 | Out-Host
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOrganization /t REG_SZ /d "$($config.Config.RegisteredOrganization)" /f /reg:64 | Out-Host

# Configure OEM branding info
if ($config.Config.OEMInfo) {
    Write-Host "Configuring OEM branding info"
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Manufacturer /t REG_SZ /d "$($config.Config.OEMInfo.Manufacturer)" /f /reg:64 | Out-Host
    reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v SupportURL /t REG_SZ /d "$($config.Config.OEMInfo.SupportURL)" /f /reg:64 | Out-Host
}

# Add system features on demand
$config.Config.AddFeatures.Feature | ForEach-Object {
    Write-Host "Adding Windows system feature: $_"
    Add-WindowsCapability -Online -Name $_
}

# Turn off (old) Edge desktop shortcut
Write-Host "Turning off (old) Edge desktop shortcut"
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v DisableEdgeDesktopShortcutCreation /t REG_DWORD /d 1 /f /reg:64 | Out-Host
#endregion

#region - Configure system region
# Set time zone
Write-Host "Setting time zone: $($config.Config.$geoid.TimeZone)"
Set-Timezone -Id $config.Config.$geoid.TimeZone

# Add language packs
if ($config.Config.$geoid.LanguagePack.Cab) {
    $config.Config.$geoid.LanguagePack.Cab | ForEach-Object {
        Write-Host "Adding language pack: $_"
        Add-WindowsPackage -Online -NoRestart -PackagePath "$($installFolder)\LPs\$_"
    }
}

# Change language
if ($config.Config.$geoid.Language) {
    Write-Host "Configuring language using: $($config.Config.$geoid.Language)"
    & $env:SystemRoot\System32\control.exe "intl.cpl,,/f:`"$($installFolder)$($config.Config.$geoid.Language)`""
}

# Add language features on demand
if ($config.Config.$geoid.AddFeatures.Feature) {
    $config.Config.$geoid.AddFeatures.Feature | ForEach-Object {
        Write-Host "Adding Windows language feature: $_"
        Add-WindowsCapability -Online -Name $_
    }
}
#endregion

Stop-Transcript
