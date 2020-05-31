function Test-FlagEnum {
    <#
    .SYNOPSIS
        Returns true if specified type is a flag enum.
    .DESCRIPTION
        Returns true if type is an enum type with FlagsAttribute specified.
    .EXAMPLE
        Test-FlagEnum "System.Text.RegularExpressions.RegexOptions"
    .EXAMPLE
        Test-FlagEnum ([int])
    #>
    param
    (
        [Type] $Type
    )

    $Type.IsEnum -and ($Type.GetCustomAttributes([System.FlagsAttribute], $true).Count -gt 0)
}