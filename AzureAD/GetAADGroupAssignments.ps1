param (
    [Parameter(Mandatory = $true)] $groupName
)

# Install the module Microsoft.Graph (https://www.powershellgallery.com/packages/Microsoft.Graph/1.4.2) before running

#Requires -Module Microsoft.Graph

# Uncomment the lines below to connect - Connect and change schema
Connect-MSGraph | Out-Null
Update-MSGraphEnvironment -SchemaVersion beta
 
#$Groups = Get-AADGroup | Get-MSGraphAllPages
$Group = Get-AADGroup -Filter "displayname eq '$GroupName'"

if (!($group)) {
    Write-Warning -Message "$groupname group not found!"
}
else {
    Write-host "AAD Group Name: $($Group.displayName)" -ForegroundColor Green
 
    # Apps
    $AllAssignedApps = Get-IntuneMobileApp -Filter "isAssigned eq true" -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments | Where-Object { $_.assignments -match $Group.id }
    Write-host "Number of Apps found: $($AllAssignedApps.DisplayName.Count)" -ForegroundColor cyan
    Foreach ($Config in $AllAssignedApps) {
        $appexclusions = $Config.assignments.target | Where-Object {$_.'@odata.type' -eq '#microsoft.graph.exclusionGroupAssignmentTarget' -and $_.groupId -eq $Group.id}
        if ($appexclusions) {
            Write-Host 'Excluded:' -ForegroundColor Magenta
            Write-host $Config.displayName -ForegroundColor Magenta
        }
        else {
            Write-Host 'Included:' -ForegroundColor Yellow
            Write-host $Config.displayName -ForegroundColor Yellow
        }
    }
     
    # Device Compliance policies
    $AllDeviceCompliance = Get-IntuneDeviceCompliancePolicy -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments | Where-Object { $_.assignments -match $Group.id }
    Write-host "Number of Device Compliance policies found: $($AllDeviceCompliance.DisplayName.Count)" -ForegroundColor cyan
    Foreach ($Config in $AllDeviceCompliance) {
        $compexclusions = $Config.assignments.target | Where-Object {$_.'@odata.type' -eq '#microsoft.graph.exclusionGroupAssignmentTarget' -and $_.groupId -eq $Group.id}
        if ($compexclusions) {
            Write-Host 'Excluded:' -ForegroundColor Magenta
            Write-host $Config.displayName -ForegroundColor Magenta
        }
        else {
            Write-Host 'Included:' -ForegroundColor Yellow
            Write-host $Config.displayName -ForegroundColor Yellow
        }
    }
     
    # Device Configuration policies
    $AllDeviceConfig = Get-IntuneDeviceConfigurationPolicy -Select id, displayName, lastModifiedDateTime, assignments -Expand assignments | Where-Object { $_.assignments -match $Group.id }
    Write-host "Number of Device Configuration policies found: $($AllDeviceConfig.DisplayName.Count)" -ForegroundColor cyan
    Foreach ($Config in $AllDeviceConfig) {
        $devconfigexclusions = $Config.assignments.target | Where-Object {$_.'@odata.type' -eq '#microsoft.graph.exclusionGroupAssignmentTarget' -and $_.groupId -eq $Group.id}
        if ($devconfigexclusions) {
            Write-Host 'Excluded:' -ForegroundColor Magenta
            Write-host $Config.displayName -ForegroundColor Magenta
            Write-Host "(Type $($Config.'@odata.type'))" -ForegroundColor Magenta
        }
        else {
            Write-Host 'Included:' -ForegroundColor Yellow
            Write-host $Config.displayName -ForegroundColor Yellow
            Write-Host "(Type $($Config.'@odata.type'))" -ForegroundColor Yellow
        }
    }
    
    # Device Configuration policies (settings catalogue)
    $scarray = @()
    $uri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies"
    $sc = Invoke-MSGraphRequest -HttpMethod GET -Url $uri
    foreach ($scpolicy in $sc.value) {
        $scassignments = Invoke-MSGraphRequest -HttpMethod GET -Url "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies('$($scpolicy.id)')/assignments"
        if ($scassignments.value.target | Where-Object { $_.groupid -match $Group.id }) {
            #Write-host "Number of Device Configurations (settings catalogue) policies found: $($scpolicy.Name.Count)" -ForegroundColor cyan
            #Write-Host $scpolicy.name -ForegroundColor Yellow
            $scarray += $scpolicy.name
        }
    }
    Write-host "Number of Device Configuration (settings catalogue) policies found: $($scarray.Count)" -ForegroundColor cyan
    foreach ($scarr in $scarray) {
        Write-Host $scarr -ForegroundColor Yellow
    }
    
    # Powershell Scripts 
    $Resource = "deviceManagement/deviceManagementScripts"
    $graphApiVersion = "Beta"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)?`$expand=groupAssignments"
    $DMS = Invoke-MSGraphRequest -HttpMethod GET -Url $uri
    $AllDeviceConfigScripts = $DMS.value | Where-Object { $_.groupAssignments -match $Group.id }
    Write-host "Number of Powershell scripts found: $($AllDeviceConfigScripts.DisplayName.Count)" -ForegroundColor cyan
    Foreach ($Config in $AllDeviceConfigScripts) {
        Write-host $Config.displayName -ForegroundColor Yellow
    }
    
    # Device administrative template policies
    $Resource = "deviceManagement/groupPolicyConfigurations"
    $graphApiVersion = "Beta"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)?`$expand=Assignments"
    $ADMT = Invoke-MSGraphRequest -HttpMethod GET -Url $uri
    $AllADMT = $ADMT.value | Where-Object { $_.assignments -match $Group.id }
    Write-host "Number of Device Administrative Templates found: $($AllADMT.DisplayName.Count)" -ForegroundColor cyan
    Foreach ($Config in $AllADMT) {
        Write-host $Config.displayName -ForegroundColor Yellow
    }
    
    # Endpoint Security policies
    $uri = "https://graph.microsoft.com/beta/deviceManagement/intents?`$filter=templateId%20eq%20%27d1174162-1dd2-4976-affc-6667049ab0ae%27%20or%20templateId%20eq%20%27a239407c-698d-4ef8-b314-e3ae409204b8%27"
    $esp = Invoke-MSGraphRequest -HttpMethod GET -Url $uri
    foreach ($esppolicy in $esp.value) {
        $espassignments = Invoke-MSGraphRequest -HttpMethod GET -Url "https://graph.microsoft.com/beta/deviceManagement/intents/$($esppolicy.id)/assignments"
        if ($espassignments.value.target | Where-Object { $_.groupid -match $Group.id }) {
            Write-host "Number of Endpoint Security policies found: $($esppolicy.DisplayName.Count)" -ForegroundColor cyan
            Write-Host $esp.value.displayname -ForegroundColor Yellow
        }
        else {
            Write-host "Number of Endpoint Security policies found: 0" -ForegroundColor cyan
        }
    }
}