function Test-Type {
    <#
    .SYNOPSIS
        Returns True if type is loaded.
    .EXAMPLE
        Test-Type System.Collections.IEnumerable
    #>
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String] $Type
    )

    try {
        $null = ([Type]$Type).Name
        return $true
    } catch {
        Write-Verbose "$Type is not loaded"
        return $false
    }
}
