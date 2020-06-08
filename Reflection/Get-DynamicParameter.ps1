function Get-DynamicParameter {
    <#
    .SYNOPSIS
        Get dynamic parameters for a command.
    .DESCRIPTION
        Get dynamic parameters for a command.
    .PARAMETER Command
        The command whose dynamic parameters you wish to get. Can take values from the pipeline.
    .PARAMETER CommandName
        The name of the command(s) whose dynamic parameters you wish to get. Can accept wildcard characters.
    .EXAMPLE
        Get-Command Get-ChildItem | Get-DynamicParameter
    .EXAMPLE
        Get-DynamicParameter Get-C*
    #>
    [Cmdletbinding(DefaultParameterSetName = 'Default', PositionalBinding = $false)]
    param
    (
        [Parameter(ParameterSetName = 'Command', Mandatory = $true, ValueFromPipeline = $true)]
        [System.Management.Automation.CommandInfo[]] $Command,

        [Parameter(ParameterSetName = 'Default', Mandatory = $true, Position = 0)]
        [string] $CommandName
    )

    begin {
        if ($PSCmdlet.ParameterSetName -eq 'Default')
        { $Command = Get-Command $CommandName }

    }

    process {
        foreach ($cmd in $Command) {
            Write-Verbose "Getting dynamic parameters for $($cmd.Name)"
            if ($cmd.Parameters) {
                $cmd.Parameters.Values.Where( { $_.IsDynamic })
            }
        }
    }
}