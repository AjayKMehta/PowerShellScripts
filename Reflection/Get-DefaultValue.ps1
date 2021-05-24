function Get-DefaultValue {
    <#
        .NOTES
        Rough equivalent to `default(T)` in C#. Only implemented for primitive types and string.
    #>
    param
    (
        [ValidateScript( { $_ -in [bool], [byte], [uint16], [uint32], [uint64], [int16], [int], [long], [float], [decimal], [double], [datetime], [guid], [string] })]
        [Type] $Type
    )

    switch ($Type) {
        ([datetime]) { [datetime]::MinValue }
        ([bool]) { $false }
        ([guid]) { [guid]::Empty }
        ([string]) { $null }
        Default { 0 }
    }
}
