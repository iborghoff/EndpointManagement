
<#PSScriptInfo

.VERSION 1.4

.GUID 28a1b634-1267-415c-891d-4afb3a72e217

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
Version 1.1: Fixed script exiting after installing required module.
Version 1.2: Fixed previous fix in 1.1.
Version 1.3: Removed the export to XLSX. The file will now be generated as a CSV.
Version 1.4: Fixed typo in Export-CSV.

#>

<#
.DESCRIPTION 
 Retrieves the User Device Registration events from the device and saves them as a log file to C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\UserDeviceRegistrationEvents.log. This allows easy collection of the log file using the 'Collect Diagnostics' action from Endpoint. Be sure to change the extension on the log file to .csv before opening it. Alternatively, specify a file name and path to save it locally as a CSV file.

 .PARAMETER outputfile
The filename and path if saving as a CSV locally

.EXAMPLE
.\Get-UserDeviceRegistrationEvents.ps1

.EXAMPLE
.\Get-UserDeviceRegistrationEvents.ps1 -logfile C:\temp\UserDeviceRegistrationEvents.csv
#>

[CmdletBinding()]
param (
    $logfile
)

# Generate log or CSV of events
Write-Host 'Getting events...' -ForegroundColor Cyan

$events = Get-WinEvent -LogName 'Microsoft-Windows-User Device Registration/Admin' -Oldest | Where-Object { $_.ID -like '4096' -or $_.ID -like '304' -or $_.ID -like '306' -or $_.ID -like '334' -or $_.ID -like '335' } | Select-Object TimeCreated, ID, ProviderName, LevelDisplayName, Message

if ($logfile) {
    $events | Export-Csv -Path "$logfile" -NoTypeInformation
    Write-Host "CSV file generated - $logfile" -ForegroundColor Green
}
else {
    $events | Export-CSV -Path 'C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\UserDeviceRegistrationEvents.log' -NoTypeInformation
    Write-Host "Log generated - C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\UserDeviceRegistrationEvents.log" -ForegroundColor Green
}