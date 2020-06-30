using namespace System.Management.Automation

function Get-ParameterValue {
    <#
    .SYNOPSIS
        Helper function to get values for all parameters.
    .DESCRIPTION
        Helper function to get values for all parameters. Apply to $PSCmdlet.MyInvocation.MyCommand to get all parameter values for the current command.
        If a parameter was passed in, it will also be in $PSBoundParameters. If a parameter is optional and there's no default value specified for it, then it will be included and its value will be the default value for the parameter type.
    .EXAMPLE
        function foo {
            [CmdletBinding()]
            param ([string] $X, [int] $Y)

            "Parameters are:"
            (Get-ParameterValue $MyInvocation -ExcludeCommon).GetEnumerator() |
            % {"{0} : {1}" -f $_.Key, $_.Value }
            "ErrorAction supplied? $($PSBoundParameters.ContainsKey('ErrorAction'))"

            "Bound parameters are: `r`n" + ($PSBoundParameters.GetEnumerator() | % {"{0} : {1}`r`n" -f $_.Key, $_.Value } )
        }

        foo -Verbose -X "A"
        foo -ErrorAction SilentlyContinue -Verbose
    .EXAMPLE
        function foo2
        {
            [CmdletBinding()]
            param
            (
                [string] $X,
                [Parameter(ParameterSetName = 'Y')][string] $Y='A'
            )
            Get-ParameterValue $PSCmdlet.MyInvocation -ParamSet $PSCmdlet.ParameterSetName
        }

        foo2 -Verbose

        foo2 -ErrorAction SilentlyContinue
        foo2 -X "A"
    #>
    [OutputType([Hashtable])]
    [Cmdletbinding(DefaultParameterSetName = 'Default', PositionalBinding = $false)]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [InvocationInfo] $Invocation,
        [ValidateNotNull()]
        [Parameter(Mandatory = $true, ParameterSetName = 'Filter', Position = 1)]
        #
        [Func[ParameterMetadata, bool]] $Filter,
        [Parameter(ParameterSetName = 'Default')]
        [switch] $ExcludeCommon,
        [Parameter(ParameterSetName = 'Default')]
        [switch] $ExcludeOptionalCommon,
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName = 'Default')]
        [string] $ParamSet
    )
    if ($PSCmdlet.ParameterSetName -eq 'Default') {
        $Filter = {
            param (
                [ParameterMetadata] $Param
            )
            if ($ExcludeCommon -and [Cmdlet]::CommonParameters.Contains($Param.Name)) {
                return $false
            }
            if ($ExcludeOptionalCommon -and [Cmdlet]::OptionalCommonParameters.Contains($Param.Name)) {
                return $false
            }
            if ($ParamSet) {
                return ($Param.ParameterSets.ContainsKey($ParamSet) -or
                    $Param.ParameterSets.ContainsKey('__AllParameterSets'))
            }
            return $true
        }
    }

    $params = @{}
    $Invocation.MyCommand.Parameters.Values.Where( { $Filter.Invoke($_) }).ForEach( {
            [string] $name = $_.Name
            [object] $value = $null

            # All cmdlet parameters with default values will exist as variables inside cmdlet.
            if ($Invocation.BoundParameters.TryGetValue($name, [ref] $value)) {
                $params[$name] = $value
            } else {
                $var = Get-Variable $name -ErrorAction SilentlyContinue -Scope 1 # Parent scope
                if ($var) { $params[$name] = $var.Value }
            }
        })

    $params
}
