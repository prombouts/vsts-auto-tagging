Write-Verbose "Entering script tagginggroup.ps1"
Write-Verbose "ResourceGroupName= $resourceGroupName"
Write-Verbose "Tags= $tagPairs"

$resources = Get-AzureRmResource -ODataQuery "`$filter=resourcegroup eq '$resourceGroupName'"

# Loop through each resource
foreach ($r in $resources)
{
    Try
    {
        foreach($line in $tagPairs -split "`n")
        {
            if ([string]::IsNullOrWhiteSpace($line))
            {
                Write-Verbose "Skipping empty line"
                continue
            }
            # Get existing tags and add a new tag
            $arr = $line.Split("{,}")

            $tagName = $arr[0]
            $tagValue = $arr[1]

            if ([string]::IsNullOrWhiteSpace($tagName) -Or
                [string]::IsNullOrWhiteSpace($tagValue))
            {
                Write-Verbose "Skipping empty tagName or tagValue"
                continue
            }

            Write-Verbose "Adding tagName $tagName tagValue $tagValue to collection"

            $r.Tags.Add($tagName, $tagValue)

            # Set the tags for this resource
            #Set-AzureRmResource  -Tag @{$arr[0]=$arr[1]} -Force
        }
        # Reapply the updated set of tags
        Write-Verbose "New tags= $r.Tags"
        Set-AzureRmResource -ResourceId $r.ResourceId -Tag $r.Tags -Force
    }
    Catch
    {
        Write-Verbose "Error when updating resource $r.ResourceId"
    }
}