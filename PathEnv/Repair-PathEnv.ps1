using namespace System.Collections.Generic

function Repair-PathEnv {
    <#
    .SYNOPSIS
        Removes non-existent and duplicate paths from PATH environment variable or string.
        Trims whitespace from existing paths.
    .DESCRIPTION
        Removes non-existent and duplicate paths from PATH environment variable or string.
        Trims whitespace from existing paths.
    .PARAMETER Target
        The environment (Machine, Process, User) whose path variable you wish to repair.
  .EXAMPLE
        Repair-PathEnv 'Machine' -WhatIf
    .EXAMPLE
        Repair-PathEnv -Path 'C:\Bogus;C:\temp;C:\temp;D:\git'
    .EXAMPLE
        'C:\Bogus;C:\temp;C:\temp;D:\git', 'D:\temp;D:\git2' | Repair-PathEnv -Confirm -Verbose
    #>
    [CmdletBinding(DefaultParameterSetName = 'Target', PositionalBinding = $false, SupportsShouldProcess = $true)]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Target', Position = 0)]
        [Alias('Target')]
        [System.EnvironmentVariableTarget] $EnvTarget = [System.EnvironmentVariableTarget]::Process,

        [Parameter(Mandatory = $true, ParameterSetName = 'Path', ValueFromPipeline = $true)]
        [string] $Path
    )
    begin {
        [bool] $useTarget = $PSCmdlet.ParameterSetName -eq 'Target'
        if ($useTarget) {
            $Path = [System.Environment]::GetEnvironmentVariable('PATH', $EnvTarget)
        }
    }
    process {
        # Filesystem paths are case-insensitive on Windows.
        [HashSet[string]] $paths = [HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        [List[string]] $badPaths = [List[string]]::new()
        [int] $len = $Path.Length
        [int] $current = 0
        [string] $val = $null;
        [string] $pathToCheck = $null;
        while ($current -lt $len - 1) {
            # Escaped entry
            if ($Path[$current] -eq '"') {
                # Find closing double quote
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
                Write-Verbose "Found non-existent path $pathToCheck"
                $null = $badPaths.Add($pathToCheck)
            } elseif (!$paths.Add($val)) {
                Write-Verbose "Found duplicate path $pathToCheck"
                $null = $badPaths.Add($pathToCheck)
            }
        }

        $res = $paths -join ';'
        if (($badPaths.Count -gt 0) -and $PSCmdlet.ShouldProcess($badPaths -join ',', 'Remove')) {
            if ($useTarget) {
                [Environment]::SetEnvironmentVariable('PATH', $res, $EnvTarget)
            } else {
                $res
            }
        } elseif (!$useTarget) {
            $Path
        }
    }
}
