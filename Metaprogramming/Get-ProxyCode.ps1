using namespace System.Management.Automation

function Get-ProxyCode {
    <#
    .SYNOPSIS
       Helper function that generates the proxy code for a command
    .EXAMPLE
        Get-ProxyCode Import-Csv
    .EXAMPLE
        Get-ProxyCode (gcm gci)
    .EXAMPLE
        gcm sls | Get-ProxyCode
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Default', Position = 0)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Command', Position = 0)]
        [Parameter(Mandatory = $true, ParameterSetName = 'CommandPipeline', ValueFromPipeline = $true)]
        [CommandInfo]
        $Command
    )

    begin {
        if ($PSCmdlet.ParameterSetName -eq 'Default') {
            try {
                $null = $PSBoundParameters.Remove('ErrorAction')
                $Command = Get-Command @PSBoundParameters -ErrorAction Stop
            } catch {
                throw
            }
        }
    }

    process {
        $metaData = [CommandMetaData]::new($command)
        $code = [ProxyCommand]::Create($metaData)

        # Add function header and indentation to the automatically-generated proxy code.
        if ($Command.CommandType -eq [CommandTypes]::Alias) {
            $Command = $Command.ResolvedCommand
        }

        "function $($Command.Name)"
        '{'

        $code -split '\r?\n' -replace '^', '    '

        '}'
    }
}
