function ConvertTo-UnixTime {
    <#
    .SYNOPSIS
        Converts a DateTime to UNIX timestamp.
    .DESCRIPTION
        Converts a DateTime to UNIX timestamp.
        UNIX timestamp is number of seconds since Jan. 1, 1970.
    .EXAMPLE
        Get-Date | ConvertTo-UnixTime
    .EXAMPLE
        ConvertTo-UnixTime '1/2/2020'
    #>
    [OutputType([long])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [Datetime]
        $InputTime
    )
    process {
        ([DatetimeOffset]$InputTime).ToUnixTimeSeconds()
    }
}