using namespace System.Text

function Add-PathEnv {
    <#
    .SYNOPSIS
        Add path entries to specified PATH environment variable or string.
    .DESCRIPTION
        Add path entries to specified PATH environment variable or string.
    .PARAMETER Target
        The environment (Machine, Process, User) whose path variable you wish to add to.
    .PARAMETER Path
        The string to which you wish to add new entries.
    .Parameter NewEntry
        The new entry you wish to add to PATH environment variable or string. This must be a valid path string.
    .PARAMETER Unique
        If set, do not add entries that already exist.
    .PARAMETER Prepend
        If set, add entries to beginning. Else, add to end (default).
    .EXAMPLE
        'C:\temp', 'D:\git', 'D:\temp' | Add-PathEnv 'C:\,%AppData%'
    #>
    [CmdletBinding(DefaultParameterSetName = 'Target', PositionalBinding = $false, SupportsShouldProcess = $true)]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Target', Position = 0)]
        [Alias('Target')]
        [System.EnvironmentVariableTarget] $EnvTarget = [System.EnvironmentVariableTarget]::Process,

        [Parameter(Mandatory = $true, ParameterSetName = 'Path', Position = 0)]
        [string] $Path,

        [ValidatePathExists(PathType = 'Container')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]] $NewEntry,

        [Parameter(Mandatory = $false)]
        [switch] $Unique,

        [Parameter(Mandatory = $false)]
        [switch] $Prepend
    )
    begin {
        [bool] $useTarget = $PSCmdlet.ParameterSetName -eq 'Target'
        if ($useTarget) {
            $Path = [System.Environment]::GetEnvironmentVariable('PATH', $EnvTarget)
            $existing = Get-PathEnv -EnvTarget $EnvTarget
        } else {
            $existing = Get-PathEnv -Path $Path
        }
        if ($Unique) {
            # Filesystem paths are case-insensitive on Windows.
            $Paths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
            $existing | ForEach-Object { $null = $Paths.Add($_) }
        }

        if ($Prepend) {
            [StringBuilder] $sb = [StringBuilder]::new($Path.Length + 100)
        } else {
            [StringBuilder] $sb = [StringBuilder]::new($Path, $Path.Length + 100)
        }
        [bool] $modify = $false
    }
    process {
        foreach ($item in $NewEntry) {
            if ((!$Unique -or !$Paths.Contains($item)) -and $PSCmdlet.ShouldProcess($item, 'Add')) {
                $modify = $true
                $entry = $item
                if ($entry.Contains([char]';')) {
                    $entry = """$entry"""
                }
                if ($Prepend) {
                    $null = $sb.Append("$entry;")
                } else {
                    $null = $sb.Append(";$entry")
                }
            }
        }
    }
    end {
        if ($Prepend) {
            $null = $sb.Append($Path)
        }
        $result = $sb.ToString()
        if ($modify) {
            if ($useTarget) {
                [Environment]::SetEnvironmentVariable('PATH', $result, $EnvTarget)
            } else {
                $result
            }
        } elseif (!$useTarget) {
            $Path
        }
    }
}
