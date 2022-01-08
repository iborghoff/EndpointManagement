<#
.SYNOPSIS
    Exports OneDrive Error Report
.DESCRIPTION
    This script exports devices which are reporting errors in the OneDrive Sync Health dashboard.
.NOTES
    Author        : Iain Piles
    Date          : 03/08/201
    Version       : 1.0
    Requirements  : ImportExcel PowerShell module (installed with the command Install-Module ImportExcel)
.PARAMETER reportpath
    Specify the path and file name of the report, you will need to include the full filename "filename.xlsx"
.PARAMETER beartoken
    Bearer token from https://config.office.com/. There is currently no API to automate getting this token.
    To get the token, start the developer tools in your browser of choice and navigate to Health > OneDrive Sync > "View devices that have sync errors" whilst watching the network tab. Look for a response such as
    "reports?top=30&filter=cast(TotalErrorCount,%27Int32%27)+ne+0&orderby=UserName+asc" and the Request Header will include the bearer token which can then be copied.
.EXAMPLE
    Export Error OneDrive Sync Report.ps1 -beartoken "ah334r2hkahihihi332423hihfasi" -reportpath "C:\temp\OneDrive Sync Report 060821.xlsx"
#>

param (
    [Parameter(Mandatory = $true)] $reportpath,
    [Parameter(Mandatory = $true)] [string]$bearertoken
)

$bearertoken = "Bearer $bearertoken"
$reportarray = @()
$report = Invoke-RestMethod -Method Get -Uri "https://canary.clients.config.office.net/odbhealth/v1.0/synchealth/reports?filter=cast(TotalErrorCount,%27Int32%27)+ne+0&orderby=UserName+asc" -Headers @{
    "authority"                 = "canary.clients.config.office.net"
    "scheme"                    = "https"
    "path"                      = "/odbhealth/v1.0/synchealth/reports?filter=cast(TotalErrorCount,%27Int32%27)+ne+0&orderby=UserName+asc"
    "x-api-name"                = "https://canary.clients.config.office.net/odbhealth/v1.0/synchealth/reports"
    "x-manageoffice-client-sid" = "b095b2a1-c688-471d-98cb-d05cab21131e"
    "x-correlationid"           = "1e5b8c76-c130-4b65-b91b-f065137c4edc"
    "sec-ch-ua-mobile"          = "?0"
    "authorization"             = "$bearertoken"
    "accept"                    = "application/json"
    "x-requested-with"          = "XMLHttpRequest"
    "user-agent"                = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36 Edg/91.0.864.41"
    "sec-ch-ua"                 = "`" Not;A Brand`";v=`"99`", `"Microsoft Edge`";v=`"91`", `"Chromium`";v=`"91`""
    "x-start-time"              = "1623340536521"
    "origin"                    = "https://config.office.com"
    "sec-fetch-site"            = "cross-site"
    "sec-fetch-mode"            = "cors"
    "sec-fetch-dest"            = "empty"
    "referer"                   = "https://config.office.com/"
    "accept-encoding"           = "gzip, deflate, br"
    "accept-language"           = "en-US,en;q=0.9"
}

Foreach ($user in $report.reports) {
    if ($user.errorDetails -eq '{}') {
        $record = @{
            "userName"                  = ""
            "userEmail"                 = ""
            "kfmState"                  = ""
            "kfmFolderCount"            = ""
            "totalErrorCount"           = ""
            "errorDetailsPrimary"       = ""
            "errorDetailsSecondary"     = ""
            "lastUpToDateSyncTimestamp" = ""
            "reportTimestamp"           = ""
            "oneDriveDeviceId"          = ""
            "deviceName"                = ""
            "oneDriveVersion"           = ""
            "updateRing"                = ""
        }
        $record."userName" = $user.userName
        $record."userEmail" = $user.userEmail 
        $record."kfmState" = $user.kfmState
        $record."kfmFolderCount" = $user.kfmFolderCount
        $record."totalErrorCount" = $user.totalErrorCount
        $record."errorDetailsPrimary" = ''
        $record."errorDetailsSecondary" = ''
        $record."lastUpToDateSyncTimestamp" = $user.lastUpToDateSyncTimestamp
        $record."reportTimestamp" = $user.reportTimestamp
        $record."oneDriveDeviceId" = $user.oneDriveDeviceId
        $record."deviceName" = $user.deviceName
        $record."oneDriveVersion" = $user.oneDriveVersion
        $record."updateRing" = $user.updateRing
        $objRecord = New-Object PSObject -property $record
        $reportarray += $objrecord
    }
    else {
        Foreach ($oderror in $user.errorDetails) {
            $record = @{
                "userName"                  = ""
                "userEmail"                 = ""
                "kfmState"                  = ""
                "kfmFolderCount"            = ""
                "totalErrorCount"           = ""
                "errorDetailsPrimary"       = ""
                "errorDetailsSecondary"     = ""
                "lastUpToDateSyncTimestamp" = ""
                "reportTimestamp"           = ""
                "oneDriveDeviceId"          = ""
                "deviceName"                = ""
                "oneDriveVersion"           = ""
                "updateRing"                = ""
            }
            $record."userName" = $user.userName
            $record."userEmail" = $user.userEmail 
            $record."kfmState" = $user.kfmState
            $record."kfmFolderCount" = $user.kfmFolderCount
            $record."totalErrorCount" = $user.totalErrorCount
            $record."errorDetailsPrimary" = $oderror.primary
            $record."errorDetailsSecondary" = $oderror.secondary
            $record."lastUpToDateSyncTimestamp" = $user.lastUpToDateSyncTimestamp
            $record."reportTimestamp" = $user.reportTimestamp
            $record."oneDriveDeviceId" = $user.oneDriveDeviceId
            $record."deviceName" = $user.deviceName
            $record."oneDriveVersion" = $user.oneDriveVersion
            $record."updateRing" = $user.updateRing
            $objRecord = New-Object PSObject -property $record
            $reportarray += $objrecord
        }
    }
}

while ($report.skipToken) {
    $report = Invoke-RestMethod -Method Get -Uri "https://canary.clients.config.office.net/odbhealth/v1.0/synchealth/reports?&skiptoken=$($report.skiptoken)&filter=cast(TotalErrorCount,%27Int32%27)+ne+0&orderby=UserName+asc" -Headers @{
        "authority"                 = "canary.clients.config.office.net"
        "scheme"                    = "https"
        "path"                      = "/odbhealth/v1.0/synchealth/reports?filter=cast(TotalErrorCount,%27Int32%27)+ne+0&orderby=UserName+asc"
        "x-api-name"                = "https://canary.clients.config.office.net/odbhealth/v1.0/synchealth/reports"
        "x-manageoffice-client-sid" = "b095b2a1-c688-471d-98cb-d05cab21131e"
        "x-correlationid"           = "1e5b8c76-c130-4b65-b91b-f065137c4edc"
        "sec-ch-ua-mobile"          = "?0"
        "authorization"             = "$bearertoken"
        "accept"                    = "application/json"
        "x-requested-with"          = "XMLHttpRequest"
        "user-agent"                = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36 Edg/91.0.864.41"
        "sec-ch-ua"                 = "`" Not;A Brand`";v=`"99`", `"Microsoft Edge`";v=`"91`", `"Chromium`";v=`"91`""
        "x-start-time"              = "1623340536521"
        "origin"                    = "https://config.office.com"
        "sec-fetch-site"            = "cross-site"
        "sec-fetch-mode"            = "cors"
        "sec-fetch-dest"            = "empty"
        "referer"                   = "https://config.office.com/"
        "accept-encoding"           = "gzip, deflate, br"
        "accept-language"           = "en-US,en;q=0.9"
    }

    Foreach ($user in $report.reports) {
        if ($user.errorDetails -eq '{}') {
            $record = @{
                "userName"                  = ""
                "userEmail"                 = ""
                "kfmState"                  = ""
                "kfmFolderCount"            = ""
                "totalErrorCount"           = ""
                "errorDetailsPrimary"       = ""
                "errorDetailsSecondary"     = ""
                "lastUpToDateSyncTimestamp" = ""
                "reportTimestamp"           = ""
                "oneDriveDeviceId"          = ""
                "deviceName"                = ""
                "oneDriveVersion"           = ""
                "updateRing"                = ""
            }
            $record."userName" = $user.userName
            $record."userEmail" = $user.userEmail 
            $record."kfmState" = $user.kfmState
            $record."kfmFolderCount" = $user.kfmFolderCount
            $record."totalErrorCount" = $user.totalErrorCount
            $record."errorDetailsPrimary" = ''
            $record."errorDetailsSecondary" = ''
            $record."lastUpToDateSyncTimestamp" = $user.lastUpToDateSyncTimestamp
            $record."reportTimestamp" = $user.reportTimestamp
            $record."oneDriveDeviceId" = $user.oneDriveDeviceId
            $record."deviceName" = $user.deviceName
            $record."oneDriveVersion" = $user.oneDriveVersion
            $record."updateRing" = $user.updateRing
            $objRecord = New-Object PSObject -property $record
            $reportarray += $objrecord
        }
        else {
            Foreach ($oderror in $user.errorDetails) {
                $record = @{
                    "userName"                  = ""
                    "userEmail"                 = ""
                    "kfmState"                  = ""
                    "kfmFolderCount"            = ""
                    "totalErrorCount"           = ""
                    "errorDetailsPrimary"       = ""
                    "errorDetailsSecondary"     = ""
                    "lastUpToDateSyncTimestamp" = ""
                    "reportTimestamp"           = ""
                    "oneDriveDeviceId"          = ""
                    "deviceName"                = ""
                    "oneDriveVersion"           = ""
                    "updateRing"                = ""
                }
                $record."userName" = $user.userName
                $record."userEmail" = $user.userEmail 
                $record."kfmState" = $user.kfmState
                $record."kfmFolderCount" = $user.kfmFolderCount
                $record."totalErrorCount" = $user.totalErrorCount
                $record."errorDetailsPrimary" = $oderror.primary
                $record."errorDetailsSecondary" = $oderror.secondary
                $record."lastUpToDateSyncTimestamp" = $user.lastUpToDateSyncTimestamp
                $record."reportTimestamp" = $user.reportTimestamp
                $record."oneDriveDeviceId" = $user.oneDriveDeviceId
                $record."deviceName" = $user.deviceName
                $record."oneDriveVersion" = $user.oneDriveVersion
                $record."updateRing" = $user.updateRing
                $objRecord = New-Object PSObject -property $record
                $reportarray += $objrecord
            }
        }
    }
}

$reportarray | Select-Object userName, userEmail, kfmState, kfmFolderCount, totalErrorCount, errorDetailsPrimary, errorDetailsSecondary, lastUpToDateSyncTimestamp, reportTimestamp, oneDriveDeviceId, deviceName, oneDriveVersion, updateRing | Export-Excel $reportpath