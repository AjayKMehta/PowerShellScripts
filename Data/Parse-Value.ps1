function Parse-Value {
    <#
    .SYNOPSIS
        Tries to cast input string to supplied type.
    .DESCRIPTION
        Tries to cast input string to supplied type. Returns object with 2 properties: IsParsed and Result.
        If IfParsed is true, result is parsed value. If IfParsed is false, result is default value for type.
    .PARAMETER Value
        String to be parsed
    .PARAMETER Type
        The type to which you wish to cast the value.
    .EXAMPLE
        Parse-Value $null 'datetime'
    .EXAMPLE
        Parse-Value 'falsE' ([bool]) -ValueOnly
    .EXAMPLE
        Parse-Value '12.123' 'double'
    #>
    param
    (
        [string] $Value,
        [ValidateScript( { $_ -in [bool], [byte], [uint16], [uint32], [uint64], [int16], [int], [long], [float], [decimal], [double], [datetime], [guid] })]
        [Type] $Type,
        [switch] $ValueOnly
    )
    #TODO: Add logic for GUID and DateTime formats.
    $result = Get-DefaultValue -Type $Type
    $success = $Type::TryParse($Value, [ref] $result)
    if ($ValueOnly) {
        $result
    } else {
        New-Object psobject -Property @{"IsParsed" = $success; "Value" = $result }
    }
}
