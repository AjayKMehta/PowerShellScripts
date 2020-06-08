filter Get-OutputType {
    <#
    .SYNOPSIS
       Returns the output type for a scriptblock if specified.
    .EXAMPLE
        $sb = { [OutputType([String])] param ([System.IO.FileInfo] $File) $File.BaseName }
        Get-OutputType $sb
    .EXAMPLE
        (Get-OutputType {}) -eq $null
    .EXAMPLE
        { [OutputType([String])] param ([System.IO.FileInfo] $File) $File.BaseName }, {[OutputType([Int])] param() $r} | Get-OutputType
    .EXAMPLE
        Get-Command Check-Parameter | Get-OutputType
    #>
    [Outputtype([System.String])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [scriptblock] $ScriptBlock
    )
    $outputType = $ScriptBlock.Attributes.Where({ $_.TypeId.Name -eq 'OutputTypeAttribute' })
    if ($outputType) { $outputType.Type.Name }
}