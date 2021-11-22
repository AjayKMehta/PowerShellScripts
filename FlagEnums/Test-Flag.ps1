function Test-Flag {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', Justification = 'Need for example code')]
    <#
    .SYNOPSIS
        Returns true if EnumValue has any (or all) flag values.
    .DESCRIPTION
        Determines whether all (any of) the bit fields in Values are set in EnumValue.
        If EnumValue's type is not an Enum type with FlagsAttribute set, then the function will throw an error.
    .PARAMETER EnumValue
        Instance of flag enum. If type is not an enum with FlagSAttribute set, then the function will throw an error!
    .PARAMETER Values
        Bit fields to check if set in EnumValue. Can be enum values, strings or numbers.
        Code will attempt to coerce the latter two to enum values.
        If it fails to convert any value, function will return false.
    .PARAMETER Check
        Either All or Any. If All, then will check if all bit fields in Values are set in EnumValue else will check any.
    .EXAMPLE
        $regexOptions = [System.Text.RegularExpressions.RegexOptions]::ExplicitCapture -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        Test-Flag $regexOptions "IgnoreCase","ExplicitCapture" 'All'
        Test-Flag $regexOptions "IgnoreCase","ExplicitCapture" Any
    .EXAMPLE
        [regex]$regex = New-Object "Regex" @("^(?<FirstName>.{7})(.{10})(?<Description>.*)$",([System.Text.RegularExpressions.RegexOptions]::ExplicitCapture -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase))
        $values = @([System.Text.RegularExpressions.RegexOptions]::ExplicitCapture, [System.Text.RegularExpressions.RegexOptions]::Multiline)
        Test-Flag $regex.Options $values All
        Test-Flag $regex.Options $values Any
    #>
    [CmdletBinding(PositionalBinding = $false)]
    param
    (
        [ValidateScript( { Test-FlagEnum ($_.GetType()) })]
        [Parameter(Mandatory = $true, Position = 0)]
        $EnumValue,
        [Parameter(Mandatory = $true, Position = 1)]
        $Values,
        [ValidateSet('Any', 'All')]
        [Parameter(Mandatory = $true, Position = 2)]
        [string] $Check
    )

    [Type] $enumType = $EnumValue.GetType()
    $enumValues =
    foreach ($value in $Values) {
        if ($newValue = $value -as $enumType) {
            $newValue
        }
    }

    $params = @{
        Values    = $enumValues
        Predicate = { param ($x) $EnumValue.HasFlag($x) }
    }

    if ($Check -eq 'All') {
        Test-All @params
    } else {
        Test-Any @params
    }
}
