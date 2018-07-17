Write-Verbose "Entering script run-vsts.ps1"

Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Initialize-Azure

$resourceGroupName = Get-VstsInput -Name resourceGroupName -Require
$tagPairs = Get-VstsInput -Name tagPairs -Require
$whenLastDeploymentIsFailed = Get-VstsInput -Name whenLastDeploymentIsFailed
$deploymentNameFilter = Get-VstsInput -Name deploymentNameFilter

.\tagginggroup.ps1