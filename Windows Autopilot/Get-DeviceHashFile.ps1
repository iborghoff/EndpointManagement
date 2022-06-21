
<#PSScriptInfo

.VERSION 1.1

.GUID 46cd79ca-bb88-41dc-b2c5-ff1959cb25f6

.AUTHOR Iain Borghoff

.COMPANYNAME 

.COPYRIGHT 

.TAGS Windows Autopilot

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Version 1.0: Initial publish.
Version 1.1: Fix typo in description.

#>

<# 
.DESCRIPTION 
 Retrieves the Windows Autopilot device hash and saves it to a CSV file

 .PARAMETER outputfile
The name and path of the CSV file to be created

.EXAMPLE
.\Get-DeviceHashFile.ps1 -OutputFile C:\temp\MyComputer.csv
#> 

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    $outputfile
)

$hash = (Get-CimInstance -Namespace root/cimv2/mdm/dmmap -Class MDM_DevDetail_Ext01 -Filter "InstanceID='Ext' AND ParentID='./DevDetail'")
$serial = (Get-CimInstance -Class Win32_BIOS).SerialNumber

$object = New-Object psobject -Property @{
    "Device Serial Number" = $serial
    "Windows Product ID"   = ''
    "Hardware Hash"        = $hash.DeviceHardwareData
}

$object | Select "Device Serial Number", "Windows Product ID", "Hardware Hash" | ConvertTo-CSV -NoTypeInformation | ForEach-Object {$_ -replace '"',''} | Out-File $outputfile