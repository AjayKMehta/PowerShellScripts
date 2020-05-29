function ConvertFrom-UnixTime {
    <#
    .SYNOPSIS
        Converts a UNIX timestap to DateTime.
    .DESCRIPTION
        Converts a UNIX timestamp to DateTime.
        UNIX timestamp is number of seconds since Jan. 1, 1970.
    .EXAMPLE
        Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' |
        Select-Object -ExpandProperty InstallDate | ConvertFrom-UnixTime
    #>
    [OutputType([DateTime])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [double]
        $UnixTime
    )
    process {
        [Datetime]::UnixEpoch.AddSeconds($UnixTime)
    }
}