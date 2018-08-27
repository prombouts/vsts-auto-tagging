Function Get-ArrayLengthValid ($arr) {
    if ($arr.length -gt 15)
    {
        Write-Output "Error: More than 15 tags are not allowed"
        exit 1
    }
}