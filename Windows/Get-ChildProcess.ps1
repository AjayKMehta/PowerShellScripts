function Get-ChildProcess {
    <#
    .SYNOPSIS
        Get child processes for a given process.
    .DESCRIPTION
        Get child processes for a given process.
    .EXAMPLE
        Get-ChildProcess 'code','pwsh'
    .EXAMPLE
        Get-ChildProcess -Id $pid
    .EXAMPLE
        gps 'pwsh', 'notepad++' | Get-ChildProcess
    .NOTES
        Based on https://reddit.com/r/PowerShell/comments/dncycf/how_to_do_i_start_and_stop_a_process_and_its/
    #>
    [CmdletBinding(DefaultParameterSetName = 'Id', PositionalBinding = $false)]
    Param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Id', ValueFromPipelineByPropertyName = $true)]
        # Id of the process
        [int[]] $Id,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true, ParameterSetName = 'Name', Position = 0)]
        # Name of the process
        [string[]] $Name
    )

    process {
        if (!$Id) {
            $Id = Get-Process -Name $Name | Select-Object -ExpandProperty Id
        }
        foreach($i in $Id) {
            Get-CimInstance win32_process -Filter "ParentProcessId = $i" | Get-Process -Id {$_.ProcessId}
        }
    }
}
