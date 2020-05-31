filter ConvertFrom-Binary {
    <#
    .SYNOPSIS
        Converts input string in binary format to a string with given encoding .
    .DESCRIPTION
        Converts input string in binary format to a string with given encoding.
    .PARAMETER InputString
        The string you want to convert from binary. Can take input from pipeline.
    .EXAMPLE
        $s = ConvertTo-Binary 'hello' -Encoding ([System.Text.Encoding]::Unicode)
        ConvertFrom-Binary $s -Encoding ([System.Text.Encoding]::Unicode)
    .EXAMPLE
        'p' | ConvertTo-Binary -Encoding ([System.Text.Encoding]::Unicode) | ConvertFrom-Binary -Encoding ([System.Text.Encoding]::Unicode)
    .EXAMPLE
        # This is OK
        'Δ' | ConvertTo-Binary -Encoding ([System.Text.Encoding]::Unicode) | ConvertFrom-Binary -Encoding ([System.Text.Encoding]::Unicode)
        # ASCII can't handle given text!
        'Δ' | ConvertTo-Binary -Encoding ([System.Text.Encoding]::Unicode) | ConvertFrom-Binary -Encoding ([System.Text.Encoding]::ASCII)
    #>
    [OutputType([string])]
    param
    (
        [ValidateNotNull()]
        [ValidateScript( { ($_.length % 8) -eq 0 })]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $InputString,

        [System.Text.Encoding] $Encoding = [System.Text.Encoding]::Default
    )
    # 8 bc 1 byte = 8 bits.
    $bytes =
    for ($i = 0; $i -lt $InputString.length; $i += 8) {
        [System.Convert]::Toint32($InputString.Substring($i, 8), 2)
    }

    $Encoding.GetString($bytes)
}