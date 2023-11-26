filter Encode-Unicode {
    <#
    .SYNOPSIS
        Converts Unicode characters in InputObject to Unicode escape sequences.
    .DESCRIPTION
        Converts Unicode characters in InputObject to Unicode escape sequences.
    .PARAMETER InputObject
        The string whose Unicode characters you wish to convert to Unicode
        escape sequences. Can take input from pipeline.
    .NOTES
        Not tested thoroughly. Use with caution!
    .OUTPUTS
        System.String
    .EXAMPLE
        '\u10A','\U10A','\u005A' | Decode-Unicode | Encode-Unicode
    .EXAMPLE
        'This sentence contains a unicode character pi (π)', '', "A" | Encode-Unicode
    .EXAMPLE
        (Encode-Unicode $null) -eq $null
    .LINK
        http://stackoverflow.com/questions/1615559/converting-unicode-strings-to-escaped-ascii-string
    #>
    param
    (
        [AllowNull()]
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        # Do not specify as String as PS will coerce $null to String.Empty!
        $InputObject
    )

    if ($null -eq $InputObject) { return $null }
    if ($InputObject -is [string]) {
        $inputText = $InputObject
    } else {
        $inputText = $InputObject.ToString()
    }

    [System.Text.StringBuilder] $sb = [System.Text.StringBuilder]::new()
    $inputText.ToCharArray().ForEach(
        {
            $val = $_
            # Non-ASCII
            if (($value = [int]$_) -gt 127) {
                $val = "\u$($value.ToString('x4'))"
            }
            $null = $sb.Append($val)
        })
    $sb.Tostring()
}
