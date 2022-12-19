You can read more about this in my post - https://www.iainborghoff.com/2022-01-10-exporting-onedrive-sync-health-reports/

**Get-OneDriveSyncReport.ps1**<br>
This function will export the data from the OneDrive Sync report (https://config.office.com/officeSettings/onedrive). This isn't an exact copy of the rendered report from the site and will instead give you the raw data. But from this data you can determine if users are for example missing one of the Known Folder Move folder (their kfmFolderCount would be less than 3).

Usage examples:
<ul>
  <li>Get-OneDriveSyncReport -bearertoken 'yourbearertoken'</li>
  <li>Get-OneDriveSyncReport -bearertoken 'yourbearertoken' | Export-Excel C:\OneDriveReport.xlsx</li>
  <li>Get-OneDriveSyncReport -bearertoken 'yourbearertoken' | Export-CSV C:\OneDriveReport.csv</li>
</ul>

**OneDriveHealthSyncReport.ps1**<br>
*This script will no longer return any results due to a change in the response format. Please use the Get-OneDriveSyncReport.ps1 function instead*
