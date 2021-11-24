filter ConvertFrom-Binary {
    <#
    .SYNOPSIS
        Converts input string in binary format to a string with given encoding .
    .DESCRIPTION
        Converts input string in binary format to a string with given encoding.
    .PARAMETER InputString
        The string you want to convert from binary. Can take input from pipeline.
    .EXAMPLE
        $s = ConvertTo-Binary -InputString 'hello' -Encoding ([System.Text.Encoding]::Unicode)
        ConvertFrom-Binary $s ([System.Text.Encoding]::Unicode)
    .EXAMPLE
        'p' |
            ConvertTo-Binary -Encoding ([System.Text.Encoding]::Unicode) |
            ConvertFrom-Binary -Encoding ([System.Text.Encoding]::Unicode)
    .EXAMPLE
        # This is OK
        'Δ' |
        ConvertTo-Binary -Encoding ([System.Text.Encoding]::Unicode) |
        ConvertFrom-Binary -Encoding ([System.Text.Encoding]::Unicode)
        # ASCII can't handle given text!
        'Δ' |
            ConvertTo-Binary -Encoding ([System.Text.Encoding]::Unicode) |
            ConvertFrom-Binary -Encoding ([System.Text.Encoding]::ASCII)
    #>
    [OutputType([string])]
    [CmdletBinding(DefaultParameterSetName = 'Default', PositionalBinding = $false)]
    param
    (
        [ValidateNotNull()]
        [ValidateScript( { ($_.Length % 8) -eq 0 })]
        [Parameter(Mandatory = $true, ParameterSetName = 'Default', Position = 0)]
        [Parameter(Mandatory = $true, ParameterSetName = 'Pipeline', ValueFromPipeline = $true)]
        [string] $InputString,

        [Parameter(Mandatory = $false, ParameterSetName = 'Default', Position = 1)]
        [Parameter(Mandatory = $false, ParameterSetName = 'Pipeline', Position = 0)]
        [System.Text.Encoding] $Encoding = [System.Text.Encoding]::Default
    )
    # 8 bc 1 byte = 8 bits.
    $bytes =
    for ($i = 0; $i -lt $InputString.length; $i += 8) {
        [System.Convert]::ToInt32($InputString.Substring($i, 8), 2)
    }

    $Encoding.GetString($bytes)
}
