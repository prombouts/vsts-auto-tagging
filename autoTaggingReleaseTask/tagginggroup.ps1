Write-Output "Entering script tagginggroup.ps1"
. "$PSScriptRoot\helpers\functions.ps1" 

Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Initialize-Azure

$resourceGroupName = Get-VstsInput -Name resourceGroupName -Require
$tagPairs = Get-VstsInput -Name tagPairs -Require
$tagResourceGroup = Get-VstsInput -Name tagResourceGroup
#$whenLastDeploymentIsFailed = Get-VstsInput -Name whenLastDeploymentIsFailed
#$deploymentNameFilter = Get-VstsInput -Name deploymentNameFilter

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

        foreach($line in $tagPairArray)
        {
            if ([string]::IsNullOrWhiteSpace($line))
            {
                Write-Output "Skipping empty line"
                continue
            }
            # Get existing tags and add a new tag
            $arr = $line.Split("{,}")

            $tagName = $arr[0]
            $tagValue = $arr[1]

            # Sanity check on empty string
            if ([string]::IsNullOrWhiteSpace($tagName) -Or
                [string]::IsNullOrWhiteSpace($tagValue))
            {
                Write-Output "Skipping pair: Empty tagName or tagValue"
                continue
            }

            # Sanity check on key/value length / For storage accounts, the tag name is limited to 128 characters, and the tag value is limited to 256 characters.
            if ($tagName.length -gt 128 -Or
                $tagValue.length -gt 256)
            {
                Write-Output "Skipping pair: Length of tagName (128 chars) or tagValue (256 chars) too large"
                continue
            }

            Write-Output "Adding tagName $tagName tagValue $tagValue to $($r.ResourceId) collection"
            # Add the tags for this resource
            $r.Tags.Add($tagName, $tagValue)
        }

        # Sanity check number of tags
        if ($r.Tags.Count -gt 15)
        {
            "Error: Combined tags resulted in more than 15 tags for resource $($r.ResourceId)"
            continue
        }

        # Reapply the updated set of tags
        Write-Output "Writing $($r.Tags.Count) tags to resource $($r.ResourceId)..."
        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $r.Tags -Force
    }
    Catch
    {
        Write-Output "Error when updating resource $($r.ResourceId)"
    }
}

# If not selected, end script
if($tagResourceGroup -eq "no")
{
    Exit 0
}

# If selected, also tag resource group
#TODO: Remove duplicate code
Try
{
    Write-Output "Found $($tagPairArray.length) tags to add to RG"
    $Tags = $resourceGroup.Tags
    foreach($line in $tagPairArray)
    {
        if ([string]::IsNullOrWhiteSpace($line))
        {
            Write-Output "Skipping empty line"
            continue
        }
        # Get existing tags and add a new tag
        $arr = $line.Split("{,}")

        $tagName = $arr[0]
        $tagValue = $arr[1]

        # Sanity check on empty string
        if ([string]::IsNullOrWhiteSpace($tagName) -Or
            [string]::IsNullOrWhiteSpace($tagValue))
        {
            Write-Output "Skipping pair: Empty tagName or tagValue"
            continue
        }

        # Sanity check on key/value length / For storage accounts, the tag name is limited to 128 characters, and the tag value is limited to 256 characters.
        if ($tagName.length -gt 128 -Or
            $tagValue.length -gt 256)
        {
            Write-Output "Skipping pair: Length of tagName (128 chars) or tagValue (256 chars) too large"
            continue
        }

        Write-Output "Adding tagName $tagName tagValue $tagValue to $($resourceGroup.ResourceId) collection"
        # Add the tags for this resource
        $Tags += @{"$tagName"="$tagValue"}
        Write-Output "Tags: $Tags"
    }

    # Sanity check number of tags
    if ($Tags.Count -gt 15)
    {
        "Error: Combined tags resulted in more than 15 tags for resource $($resourceGroup.ResourceId)"
        continue
    }

    # Reapply the updated set of tags
    Write-Output "Writing $($Tags.Count) tags to resourcegroup $($resourceGroupName)..."
    Set-AzureRmResourceGroup -Name "$resourceGroupName" -Tag $Tags
}
Catch
{
    Write-Output "Error when updating resourcegroup $($resourceGroupName)"
}