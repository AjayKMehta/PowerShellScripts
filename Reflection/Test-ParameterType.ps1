
function Test-ParameterType {
    <#
    .SYNOPSIS
       Returns true if all the parameters of the scriptblock match the inputed types.
    .EXAMPLE
        $sb = { param ([int] $x, [bool] $flag)  if ($flag) {$x} else {-1} }
        Test-ParameterType $sb ([System.IO.FileInfo])
    .EXAMPLE
        Test-ParameterType { param ([int32] $a, [string] $b) } @([System.Int64],[System.Boolean])
    .EXAMPLE
        Test-ParameterType { param ([int32] $a, [string] $b) } @('System.Int32', 'System.String')
    #>
    [Outputtype([bool])]
    [CmdletBinding(DefaultParametersetName = "ExpectedTypes")]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [scriptblock]
        $ScriptBlock,

        [Parameter(ParameterSetName = "ExpectedTypes", Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [Type[]]
        $ExpectedTypes,

        # Array of expected type names
        [Parameter(ParameterSetName = "TypeNames", Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [string[]]
        $TypeNames
    )
    if ($PSCmdlet.ParameterSetName -eq "TypeNames") {
        $ExpectedTypes = $TypeNames.ForEach( { [Type]::GetType($_, $true) })
    }

    $params = $ScriptBlock.Ast.ParamBlock
    if ($null -eq $params) { return $false }
    @(Compare-Object $params.Parameters.StaticType $ExpectedTypes).Count -eq 0
}