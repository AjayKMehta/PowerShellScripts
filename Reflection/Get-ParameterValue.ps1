function Get-ParameterValue {
    <#
    .SYNOPSIS
        Helper function to get values for all parameters.
    .DESCRIPTION
        Helper function to get values for all parameters. Apply to $PSCmdlet.MyInvocation.MyCommand to get all parameter values.
        If a parameter was passed in, it will also be in $PSBoundParameters. If a parameter is optional and there's no default value specified for it, then the value will be the default value for the parameter type.
    .EXAMPLE
        function foo
        {
            [CmdletBinding()]
            param ([string] $X, [int] $Y)

            Get-ParameterValue $pscmdlet.MyInvocation.MyCommand
            "Parameters are:"
            (Get-ParameterValue $MyInvocation.MyCommand -ExcludeCommon).GetEnumerator() |
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
            "Params common to all parameter sets:"
            Get-ParameterValue $PSCmdlet.MyInvocation.MyCommand -ParamSet '__AllParameterSets'
        }

        foo2 -Verbose

        foo2 -ErrorAction SilentlyContinue
        foo2 -X "A"
    #>
    [Cmdletbinding(DefaultParameterSetName = 'Filter', PositionalBinding = $false)]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.Management.Automation.CommandInfo] $Cmd,
        [Parameter(ParameterSetName = 'Filter', Position = 1)]
        [ScriptBlock] $Filter = { $true },
        [Parameter(ParameterSetName = 'Switch')]
        [switch] $ExcludeCommon,
        [Parameter(ParameterSetName = 'Switch')]
        [switch] $ExcludeOptionalCommon,
        [Parameter(ParameterSetName = 'ParamSet')]
        [string] $ParamSet
    )

    switch ($PSCmdlet.ParameterSetName) {
        'Switch' {
            $excluded = @()
            if ($ExcludeCommon) { $excluded = [System.Management.Automation.Cmdlet]::CommonParameters }
            if ($ExcludeOptionalCommon) { $excluded += [System.Management.Automation.Cmdlet]::OptionalCommonParameters }

            if ($excluded.Count -gt 0) {
                $Filter = { $excluded -notcontains $_.Name }
            }
        }

        'ParamSet' {
            $Filter = { $_.ParameterSets.ContainsKey($ParamSet) }
        }
    }

    $params = @{}
    # All cmdlet parameters with default values will exist as variables inside cmdlet.
    $Cmd.Parameters.Values.Where($Filter).ForEach( {
            [string] $name = $_.Name
            $var = Get-Variable $name -ErrorAction SilentlyContinue -Scope 1 # Parent scope
            if ($var) { $params[$name] = $var.Value }
        })

    $params
}
