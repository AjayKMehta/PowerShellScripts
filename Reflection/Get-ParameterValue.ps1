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
            param ([Datetime] $MyDate = (Get-Date), [int] $Y)
            "Parameters are:"
            (Get-ParameterValue $MyInvocation -ExcludeCommon).GetEnumerator() |
            ForEach-Object { "{0} : {1}" -f $_.Key, $_.Value }
        }

        foo -Verbose -MyDate '3/4/2020'
        # Parameters are:
        # MyDate : 3/4/2020 12:00:00 AM
        # Y : 0
        foo -ErrorAction SilentlyContinue -Verbose
        # Parameters are:
        # MyDate : 6/30/2020 3:03:37 PM
        # Y : 0
    .EXAMPLE
        function foo2 {
            [CmdletBinding(DefaultParameterSetName = 'Y')]
            param
            (
                [int] $X,
                [Parameter(ParameterSetName = 'Y')][string] $Y = 'A',
                [Parameter(ParameterSetName = 'Z')][string] $Z = 'B'
            )
            Get-ParameterValue $PSCmdlet.MyInvocation -ParamSet $PSCmdlet.ParameterSetName
        }

        foo2 -Verbose
        # @{Y = 'A'; X = 0; Verbose = $True}
        foo2 -ErrorAction SilentlyContinue
        # @{Y = 'A'; X = 0; ErrorAction = 'SilentlyContinue'}
        foo2 -Z 'C'
        # @{X = 0; Z = 'C'}
        foo2 -X 3
        # @{Y = 'A'; X = 3}
    #>
    [OutputType([Hashtable])]
    [Cmdletbinding(DefaultParameterSetName = 'Default', PositionalBinding = $false)]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        # Inovcation for which you wish to retrieve parameter values
        [InvocationInfo] $Invocation,

        [ValidateNotNull()]
        [Parameter(Mandatory = $true, ParameterSetName = 'Filter', Position = 1)]
        # Delegate used to select parameters based on metadata
        [Func[ParameterMetadata, bool]] $Filter,

        [Parameter(ParameterSetName = 'Default')]
        # If set, exclude common parameters, e.g. Verbose.
        [switch] $ExcludeCommon,

        [Parameter(ParameterSetName = 'Default')]
        # If set, exclude optional common parameters, e.g. WhatIf.
        [switch] $ExcludeOptionalCommon,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName = 'Default')]
        # Name of parameterset for which you want parameter values.
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
