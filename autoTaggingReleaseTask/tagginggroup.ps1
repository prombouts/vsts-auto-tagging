Write-Output "Entering script tagginggroup.ps1"
. "$PSScriptRoot\helpers\functions.ps1" 

Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Initialize-Azure

#$resourceGroupName = Get-VstsInput -Name resourceGroupName -Require
#$tagPairs = Get-VstsInput -Name tagPairs -Require
#$tagResourceGroup = Get-VstsInput -Name tagResourceGroup

$resourceGroupName = "rg-jordin-data"
$tagPairs = "Hello,World
TestPair,TestValue"
#$tagResourceGroup = Get-VstsInput -Name tagResourceGroup


Write-Output "ResourceGroupName= $resourceGroupName"
Write-Output "Tags= $tagPairs"
Write-Output "tagResourceGroup= $tagResourceGroup"

$resources = Get-AzureRmResource -ODataQuery "`$filter=resourcegroup eq '$resourceGroupName'"
$resourceGroup = Get-AzureRmResourceGroup -Name "$resourceGroupName"

$tagPairArray = $tagPairs -split "`n"

# Sanity check number of tags
Get-ArrayLengthValid($tagPairArray)

# Loop through each resource
foreach ($r in $resources)
{
    Try
    {
        Write-Output "Found $($tagPairArray.length) tags to add"
        
        Set-TagsOnResource $r $tagPairArray
    }
    Catch
    {
        Write-Output "Set-TagsOnResource: Error when updating resource $($r.ResourceId)"
        Write-Output "$_.Exception"
    }
}

# If not selected, end script
if($tagResourceGroup -eq "no")
{
    Exit 0
}

# If selected, also tag resource group
Try
{
    Write-Output "Found $($tagPairArray.length) tags to add to RG"
    Set-TagsOnResourceGroup $resourceGroup $tagPairArray
}
Catch
{
    Write-Output "Set-TagsOnResourceGroup: Error when updating resourcegroup $($resourceGroupName)"
    Write-Output "$_.Exception"
}