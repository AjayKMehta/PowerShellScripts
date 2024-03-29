filter ConvertTo-Binary {
    <#
    .SYNOPSIS
        Converts a string with given encoding to binary.
    .DESCRIPTION
        Converts a string with given encoding to binary.
    .PARAMETER InputString
        The string you want to convert to binary. Can take input from pipeline.
    .EXAMPLE
        '\u10A', '\u005C' | ConvertTo-Binary -Encoding ([System.Text.Encoding]::Unicode)
    .EXAMPLE
        ConvertTo-Binary -InputString 'hello'
    .EXAMPLE
        ConvertTo-Binary 'hello' ([System.Text.Encoding]::ASCII)
    .LINK
        http://stackoverflow.com/questions/6285722/c-sharp-binary-to-string?lq=1
    #>
    [OutputType([string])]
    [CmdletBinding(DefaultParameterSetName = 'Default', PositionalBinding = $false)]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Default', Position = 0)]
        [Parameter(Mandatory = $true, ParameterSetName = 'Pipeline', ValueFromPipeline = $true)]
        [string] $InputString,

        [Parameter(Mandatory = $true, ParameterSetName = 'Default', Position = 1)]
        [Parameter(Mandatory = $true, ParameterSetName = 'Pipeline', Position = 0)]
        [System.Text.Encoding] $Encoding = [System.Text.Encoding]::Default
    )
    # 8 bc 1 byte = 8 bits.
    $Encoding.GetBytes($InputString).ForEach( { [System.Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ''
}
