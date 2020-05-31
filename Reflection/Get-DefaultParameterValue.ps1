function Get-DefaultParameterValue {
    <#
    .SYNPOSIS
        Returns name and default value for parameters of given command or scriptblock.
    .DESCRIPTION
        Returns names of parameters along with their default values for given command or scriptblock.
    .NOTES
        This only works for functions written in PowerShell. This will not work for commands in binary modules.
    .EXAMPLE
       $sb = { param ($a = 1, $b, $c) $a + 1 }
       Get-DefaultParameterValue $sb
    .EXAMPLE
        function foo
        {
            param
            (
                $a = 1, $b, $c
            )

            $a + 1
        }

        Get-DefaultParameterValue -Command (Get-Command foo)
    .EXAMPLE
        Get-DefaultParameterValue -Command (Get-Command Get-Variable)
    #>
    [Cmdletbinding(DefaultParameterSetName = 'ScriptBlock')]
    param
    (
        [ValidateNotNull()]
        [Parameter(ParameterSetName = 'ScriptBlock', Mandatory = $true, Position = 0)]
        [ScriptBlock] $ScriptBlock,

        [ValidateNotNull()]
        [Parameter(ParameterSetName = 'Command', Mandatory = $true)]
        [System.Management.Automation.CommandInfo] $Command
    )

    switch ($PSCmdlet.ParameterSetName) {
        'ScriptBlock' {
            $ScriptBlock.Ast.ParamBlock.Parameters |
            Where-Object DefaultValue |
            Select-Object Name, DefaultValue
        }
        'Command' {
            $Command.ScriptBlock.Ast.Body.ParamBlock.Parameters |
            Where-Object DefaultValue |
            Select-Object Name, DefaultValue
        }
    }
}