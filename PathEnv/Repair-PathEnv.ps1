using namespace System.Collections.Generic
function Repair-PathEnv {
    <#
    .SYNOPSIS
        Removes non-existent and duplicate paths from PATH environment variable or string.
        Trims existing paths.
    .DESCRIPTION
        Removes non-existent and duplicate paths from PATH environment variable or string.
        Trims existing paths.
    .PARAMETER Target
        The environment (Machine, Process, User) whose path variable you wish to inspect.
    .NOTES
        Since this is a potentially dangerous operation and the cmdlet has no risk mitigation
        parameters, it is recommended you first use the parameter set that takes a string as input
        to make sure you are comfortable with the expected results:

        $null = [System.Environment]::GetEnvironmentVariable('Path') | Repair-PathEnv -Verbose
        # If happy, go ahead:
        Repair-PathEnv -Target Process -Verbose
    .EXAMPLE
        Repair-PathEnv 'Machine'
    .EXAMPLE
        Repair-PathEnv -Path 'C:\Bogus;C:\temp;C:\temp;D:\git'
    #>
    [CmdletBinding(DefaultParameterSetName = 'Target')]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Target', Position = 0)]
        [Alias('Target')]
        [System.EnvironmentVariableTarget] $EnvTarget = [System.EnvironmentVariableTarget]::Process,

        [Parameter(Mandatory = $true, ParameterSetName = 'Path', ValueFromPipeline = $true)]
        [string] $Path
    )
    [HashSet[string]] $paths = [HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)

    if ($PSCmdlet.ParameterSetName -eq 'Target') {
        $Path = [System.Environment]::GetEnvironmentVariable('PATH', $EnvTarget)
    }
    [int] $len = $Path.Length
    [int] $current = 0
    [bool] $modify = $false
    [string] $val = $null;
    [string] $pathToCheck = $null;
    while ($current -lt $len - 1) {
        if ($Path[$current] -eq '"') {
            $end = $Path.IndexOf([char] '"', $current + 1)
            if ($end -eq -1 -or ($end -lt $len - 1 -and $Path[$end + 1] -ne ';')) {
                throw "Malformed text"
            }

            $val = $Path.Substring($current, $end - $current + 1).Trim()
            # Remove quotes
            $pathToCheck = $Path.Substring($current + 1, $end - $current - 1).Trim()
            $current = $end + 2
        } else {
            $end = $Path.IndexOf([char] ';', $current + 1)
            if ($end -eq -1) {
                $end = $len
            }
            $val = $Path.Substring($current, $end - $current).Trim()
            $pathToCheck = $val
            $current = $end + 1
        }
        if (!(Test-Path -LiteralPath $pathToCheck)) {
            Write-Verbose "Remove non-existent path $pathToCheck"
            $modify = $true
        } elseif (!$paths.Add($val)) {
            Write-Verbose "Remove duplicate path $val"
            $modify = $true
        }
    }

    $res = $paths -join ';'
    if ($PSCmdlet.ParameterSetName -eq 'Target') {
        if ($modify) {
            [Environment]::SetEnvironmentVariable('PATH', $res, $EnvTarget)
        }
    } else {
        $res
    }
}
