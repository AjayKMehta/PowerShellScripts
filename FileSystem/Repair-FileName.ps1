filter Repair-FileName {
    <#
    .SYNOPSIS
        Removes invalid file characters from input.
    #>
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string] $Name,
        [string] $ReplaceWith = ''
    )
    [string] $result = $Name
    foreach ($c in [System.IO.Path]::GetInvalidFileNameChars() ) {
        $result = $result.Replace([string]$c, $ReplaceWith)
    }
    $result
}