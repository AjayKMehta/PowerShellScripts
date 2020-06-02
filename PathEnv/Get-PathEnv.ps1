<#
.SYNOPSIS
    Get paths specified in input PATH environment variable or string.
.DESCRIPTION
    Get paths specified in PATH environment variable or string.
.PARAMETER Target
    The environment (Machine, Process, User) whose path variable you wish to inspect.
.PARAMETER Path
    The string whom you wish to split into its component paths.
.NOTES
    This will automatically trim paths returned. If used with Path as opposed to Target, environment variables will not be replaced by their corresponding values in returned results, e.g. it will not replace %TMP% with "C:\Users\$($env:UserName)\AppData\Local\Temp".
.EXAMPLE
    Get-PathEnv -Path 'C:\temp; D:\git'
.EXAMPLE
    Get-PathEnv -Path 'C:\temp; D:\git;"D:\temp\test;"'

    Output is:
    C:\temp
    D:\git
    D:\temp\test;
.EXAMPLE
    Get-PathEnv -Path 'C:\temp;"D:\temp\test;";%AppData%\code'

    Output is:
    C:\temp
    D:\temp\test;
    %AppData%\code

    Notice how this does not replaces %AppData% with its value!
.EXAMPLE
    Get-PathEnv 'Machine' | Out-File C:\temp\path-test.txt -Encoding UTF8
#>
function Get-PathEnv {
    [CmdletBinding(DefaultParameterSetName = 'Target')]
    [OutputType([String[]])]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Target', Position = 0)]
        [Alias('Target')]
        [System.EnvironmentVariableTarget] $EnvTarget = [System.EnvironmentVariableTarget]::Process,

        [Parameter(Mandatory = $true, ParameterSetName = 'Path', ValueFromPipeline = $true)]
        [string] $Path

    )
    begin {
        if ($PSCmdlet.ParameterSetName -eq 'Target') {
            $Path = [System.Environment]::GetEnvironmentVariable('Path', $EnvTarget)
        }
    }
    process {
        [int] $len = $Path.Length
        [int] $current = 0
        while ($current -lt $len - 1) {
            if ($Path[$current] -eq '"') {
                $end = $Path.IndexOf([char] '"', $current + 1)
                if ($end -eq -1 -or ($end -lt $len - 1 -and $Path[$end + 1] -ne ';')) {
                    throw "Malformed text"
                }
                $Path.Substring($current + 1, $end - $current - 1).Trim()
                $current = $end + 2
            } else {
                $end = $Path.IndexOf([char] ';', $current + 1)
                if ($end -eq -1) {
                    $end = $len
                }
                $Path.Substring($current, $end - $current).Trim()
                $current = $end + 1
            }
        }
    }
}
