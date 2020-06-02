filter Repair-PathName {
    <#
    .SYNOPSIS
        Removes invalid path characters from input.
    #>
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string] $Name,
        [string] $ReplaceWith = ''
    )
    [string] $result = $Name
    foreach ($c in [System.IO.Path]::GetInvalidPathChars() ) {
        $result = $result.Replace([string]$c, $ReplaceWith)
    }
    $result
}
