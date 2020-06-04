using namespace System.Text.RegularExpressions
function Decode-Unicode {
    <#
    .SYNOPSIS
        Converts Unicode escape sequences in InputObject to Unicode characters.
    .DESCRIPTION
        Converts Unicode escape sequences in InputObject to Unicode characters.
    .PARAMETER InputObject
        The string whose Unicode escape sequences you wish to convert to Unicode characters. Can take input from pipeline.
    .NOTES
        Not tested thoroughly. Use with caution!
    .EXAMPLE
        '\u10A','\U10A','\u005A', $null | Decode-Unicode
    .EXAMPLE
        'This sentence contains a unicode character pi (\u03c0)', '', "A" | Decode-Unicode
    .EXAMPLE
        (Decode-Unicode $null) -eq $null
    .LINK
        http://stackoverflow.com/questions/1615559/converting-unicode-strings-to-escaped-ascii-string
    #>
    param
    (
        [AllowNull()]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $InputObject
    )

    begin {
        $regex = New-Object Regex @("\\u(?<Value>[a-f0-9]+)", ([RegexOptions]::Compiled -bor [RegexOptions]::IgnoreCase))
    }

    process {
        if ($null -eq $InputObject) { return $null }
        if ($InputObject -is [string]) {
            $inputText = $InputObject
        } else {
            $inputText = $InputObject.ToString()
        }
        $regex.Replace($inputText, { param ($m) ([char]([int]::Parse($m.groups["Value"].Value, [System.Globalization.NumberStyles]::HexNumber))).ToString() })
    }

    end { $regex = $null }
}
